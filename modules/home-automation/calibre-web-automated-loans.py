import argparse
import importlib
import sys

LOCK_NAME = "__acsm_plugin_execute_run_acsm_file"


def load_deacsm():
    calibre_ui = importlib.import_module("calibre.customize.ui")
    calibre_lock = importlib.import_module("calibre.utils.lock")
    calibre_ui.initialize_plugins()

    try:
        fulfill = importlib.import_module(
            "calibre_plugins.deacsm.libadobeFulfill"
        )
        prefs = importlib.import_module("calibre_plugins.deacsm.prefs")
    except ImportError as error:
        raise RuntimeError(
            "DeACSM is not installed in CWA's Calibre configuration"
        ) from error

    prefs_class = getattr(prefs, "ACSMInput_Prefs", None)
    if prefs_class is None:
        prefs_class = getattr(prefs, "DeACSM_Prefs", None)
    if prefs_class is None:
        raise RuntimeError("Unsupported DeACSM preferences API")

    return prefs_class, fulfill.tryReturnBook, calibre_lock.SingleInstance


def refresh_prefs(prefs):
    refresh = getattr(prefs, "refresh", None)
    if refresh is not None:
        refresh()


def save_prefs(prefs):
    commit = getattr(prefs, "commit", None)
    if commit is not None:
        commit()
        return

    writeprefs = getattr(prefs, "writeprefs", None)
    if writeprefs is None:
        raise RuntimeError("Unsupported DeACSM preferences persistence API")
    writeprefs()


def list_loans(loans):
    if not loans:
        print("No active DeACSM loan records.")
        return

    for loan in loans:
        print(f"Title:   {loan.get('book_name') or '(unknown title)'}")
        print(f"Loan ID: {loan.get('loanID') or '(missing)'}")
        print(f"Due:     {loan.get('validUntil') or '(unknown)'}")
        print(f"Server:  {loan.get('operatorURL') or '(unknown)'}")
        print()


def find_loan(loans, loan_id):
    matches = [loan for loan in loans if loan.get("loanID") == loan_id]
    if not matches:
        raise RuntimeError(f"No DeACSM loan record has ID {loan_id}")
    if len(matches) != 1:
        raise RuntimeError(
            f"Refusing to return loan ID {loan_id}: {len(matches)} records matched"
        )
    return matches[0]


def return_loan(prefs, try_return_book, loan_id):
    refresh_prefs(prefs)
    loans = prefs["list_of_rented_books"]
    loan = find_loan(loans, loan_id)

    print(f"Returning {loan.get('book_name') or '(unknown title)'} ({loan_id})...")
    success, response = try_return_book(loan)
    if not success:
        raise RuntimeError(f"DeACSM rejected the return: {response}")

    prefs["list_of_rented_books"].remove(loan)
    save_prefs(prefs)
    print("Book successfully returned and its local loan record was removed.")


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description="List or return library loans fulfilled by DeACSM in CWA."
    )
    subcommands = parser.add_subparsers(dest="command")
    subcommands.add_parser("list", help="list active DeACSM loan records")

    return_parser = subcommands.add_parser(
        "return", help="return exactly one loan by its DeACSM loan ID"
    )
    return_parser.add_argument("loan_id")

    args = parser.parse_args(argv)
    if args.command is None:
        args.command = "list"
    return args


def main(argv=None):
    args = parse_args(sys.argv[1:] if argv is None else argv)
    prefs_class, try_return_book, single_instance = load_deacsm()

    with single_instance(LOCK_NAME) as acquired:
        if not acquired:
            raise RuntimeError(
                "DeACSM is currently processing another book; try again shortly"
            )

        prefs = prefs_class()
        refresh_prefs(prefs)
        if args.command == "list":
            list_loans(prefs["list_of_rented_books"])
        else:
            return_loan(prefs, try_return_book, args.loan_id)

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(1)
