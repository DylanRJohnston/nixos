"""Focused black-box CLI tests; fake Nix only, no network or store changes."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).with_name('offload-build')
INSTALLABLE = '.#nixosConfigurations.mimir.config.system.build.toplevel'
REMOTE = 'ssh://eu.nixbuild.net aarch64-linux /etc/ssh/ssh_host_ed25519_key 1 1'
FAKE = '''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
root = Path(os.environ['FAKE_ROOT'])
a = sys.argv[1:]
with (root / 'calls').open('a') as f:
    f.write(json.dumps(a) + '\\n')
if a[:2] == ['derivation', 'show']:
    print((root / 'graph').read_text())
elif a[0] == 'build':
    sys.exit(1 if os.environ.get('FAIL_STAGE') == ('verify' if '--offline' in a else 'cloud' if '--builders' in a else 'prep') else 0)
else:
    sys.exit(99)
'''


def fixture(legacy=False):
    graph = {}
    # The intermediate dependency forces ordering through nonselected jobs.
    for name, dependencies in [('dep', {}), ('nix-z-tests-run', {'dep': ['dev']}),
                               ('bridge', {'nix-z-tests-run': ['out']}),
                               ('nix-a-tests-run', {'bridge': ['out']}),
                               ('system', {'nix-a-tests-run': ['out']})]:
        prefix = '/nix/store/' if legacy else ''
        drv = {'name': name, 'system': 'aarch64-linux'}
        inputs = {prefix + dep + '.drv': outputs for dep, outputs in dependencies.items()}
        if legacy:
            drv['inputDrvs'] = inputs
        else:
            drv['inputs'] = {'drvs': {dep: {'outputs': outputs, 'dynamicOutputs': {}}
                                     for dep, outputs in inputs.items()}}
        graph[prefix + name + '.drv'] = drv
    return graph if legacy else {'version': 4, 'derivations': graph}


class CLITest(unittest.TestCase):
    def run_cli(self, args=(), graph=None, fail=''):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / 'nix').write_text(FAKE)
            (root / 'nix').chmod(0o755)
            (root / 'graph').write_text(json.dumps(graph or fixture()))
            env = dict(os.environ, PATH=temp + os.pathsep + os.environ['PATH'],
                       FAKE_ROOT=temp, FAIL_STAGE=fail)
            result = subprocess.run([str(SCRIPT), *args], env=env, text=True,
                                    capture_output=True, timeout=10)
            calls = [json.loads(line) for line in (root / 'calls').read_text().splitlines()]
            return result, calls

    def test_dry_run_defaults_and_custom_glob(self):
        for legacy in (False, True):
            for args, count in [(['--dry-run'], 2), (['nix-a-*', '--dry-run'], 1)]:
                result, calls = self.run_cli(args, fixture(legacy))
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(calls, [['derivation', 'show', '--recursive', INSTALLABLE]])
                self.assertEqual(result.stdout.count('Selected:'), count)

    def test_dependency_order_default_builders_and_offline_reuse(self):
        for legacy in (False, True):
            result, calls = self.run_cli(graph=fixture(legacy))
            self.assertEqual(result.returncode, 0, result.stderr)
            builds = calls[1:]
            self.assertEqual([c[-1] for c in builds], [
                '/nix/store/dep.drv^dev', '/nix/store/nix-z-tests-run.drv^*',
                '/nix/store/nix-z-tests-run.drv^*', '/nix/store/bridge.drv^out',
                '/nix/store/nix-a-tests-run.drv^*', '/nix/store/nix-a-tests-run.drv^*'])
            for c in builds:
                self.assertEqual(c[c.index('--store') + 1], 'daemon')
                self.assertIn('--no-link', c)
            for c in builds[::3]:
                self.assertNotIn('--builders', c)
                self.assertNotIn('--max-jobs', c)
            for c in builds[1::3]:
                self.assertEqual(c[c.index('--builders') + 1], REMOTE)
                self.assertEqual(c[c.index('--max-jobs') + 1], '0')
            for c in builds[2::3]:
                self.assertIn('--offline', c)
                self.assertEqual(c[c.index('--builders') + 1], '')
                self.assertEqual(c[c.index('--max-jobs') + 1], '0')

    def test_no_matches_and_unsupported_system_do_not_build(self):
        result, calls = self.run_cli(['absent*'])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('No derivation names match', result.stderr)
        self.assertEqual(len(calls), 1)
        graph = fixture()
        graph['derivations']['nix-a-tests-run.drv']['system'] = 'x86_64-linux'
        result, calls = self.run_cli(graph=graph)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Only aarch64-linux', result.stderr)
        self.assertEqual(len(calls), 1)

    def test_failed_preparation_offload_or_verification_stops(self):
        for stage, count in [('prep', 2), ('cloud', 3), ('verify', 4)]:
            result, calls = self.run_cli(fail=stage)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(len(calls), count)

    def test_dynamic_dependencies_rejected_before_build(self):
        graph = fixture()
        graph['derivations']['nix-z-tests-run.drv']['inputs']['drvs']['dep.drv']['dynamicOutputs'] = {'out': {}}
        result, calls = self.run_cli(graph=graph)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Dynamic dependency outputs', result.stderr)
        self.assertEqual(len(calls), 1)


if __name__ == '__main__':
    unittest.main()
