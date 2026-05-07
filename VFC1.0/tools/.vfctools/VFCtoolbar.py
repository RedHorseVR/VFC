import os
import sys
import subprocess
import pyperclip
import webbrowser
from PyQt5 import uic
from colorama import Fore, Style, init

init()
from PyQt5.QtWidgets import QApplication, QDialog
from PyQt5.QtCore import Qt, QEvent


#  Load the .ui file (must be in the same directory as this script)
UI_FILE = os.path.join(os.path.dirname(__file__), "VFCtoolbar.ui")


def clean(s):
    clean = ""
    for line in s.splitlines(keepends=False):

        if line != "\n":
            clean = clean + line + "\n"

    return clean.rstrip()


class ToolbarApp(QDialog):
    def __init__(self):
        super().__init__()
        self.setStyleSheet("background-color: rgb(31, 128, 255) ; color: white;")  # self.setStyleSheet("background-color: #1F1F7A;")
        uic.loadUi(UI_FILE, self)
        self.setWindowTitle("VFC Tools")

        self.setWindowFlags(  # ////
            self.windowFlags()
            | Qt.WindowStaysOnTopHint  # ////
            # & ~Qt.WindowContextHelpButtonHint
        )  # ////
        #  Wire buttons defined in the .ui file
        QApplication.instance().installEventFilter(self)
        self.showClipboard.clicked.connect(self.print_clipboard)  # "Show Clipboard"
        self.openWorkspace.clicked.connect(self.open_current_dir)  # "Open Workspace"
        self.flowClipboard.clicked.connect(self.flow_clipboard)
        self.openCLI.clicked.connect(self.open_cli)
        self.openXMIND.clicked.connect(self.open_xmind)

    def eventFilter(self, obj, event):
        if event.type() == QEvent.EnterWhatsThisMode:
            QApplication.instance().removeEventFilter(self)
            webbrowser.open("https://github.com/RedHorseVR/VFlow")
            return True

        return super().eventFilter(obj, event)

        #  --- Actions ---

    def flow_clipboard(self):
        os.system("cls" if os.name == "nt" else "clear")
        content = pyperclip.paste()
        path = os.getcwd()
        print("=== FLOWING CLIPBOARD CONTENT ===")
        with open("temp.txt", "w", encoding="ascii", errors="backslashreplace") as f:
            print("------------------------------------------------")
            f.write(clean(content))

        flowcmd = "vfc temp.txt"  # flowcmd = "PYPARSE.bat temp.txt"
        # vfccmd = "C:\\Program Files\\VFCode\\VFC1.0t temp.txt.vfc -Reload"
        print(flowcmd)
        os.system(flowcmd)  # os.system( "dir temp.txt" )

    def print_clipboard(self):
        # os.system("cls" if os.name == "nt" else "clear")
        content = pyperclip.paste()
        os.system("cls")
        os.system("color B1")
        print(Fore.YELLOW + "", end="")
        print("=== CLIPBOARD CONTENT ===")
        print("------------------------------------------------")
        print(Fore.BLUE + "", end="")
        print(clean(content))
        print(Fore.YELLOW + "------------------------------------------------")

    def open_current_dir(self):
        path = os.getcwd()
        if os.name == "nt":  # Windows #beginif
            os.startfile(path)
        elif os.name == "posix":  # macOS / Linux
            subprocess.run(["open" if sys.platform == "darwin" else "xdg-open", path])

    def open_cli(self):
        path = os.getcwd()
        os.system(' start cmd /k "color 1F & title VFC TOOLBAR: CLI"')  # os.system( "start cmd /k color 1F" )

    def open_xmind(self):
        path = os.getcwd()
        cmd = "start VFlow.xmind"
        os.system(cmd)

        #  --- Easy extension helper ---

    def add_button(self, label, func):
        """Dynamically wire any QPushButton added to the .ui file later."""
        btn = self.findChild(type(self.pushButton), label)
        if btn:
            btn.clicked.connect(func)


if __name__ == "__main__":
    os.system("title VFC TOOLBAR: CLIPBOARD")  # ////
    os.system("color B1")
    # os.system("mode con: cols=50 lines=30")

    app = QApplication(sys.argv)
    window = ToolbarApp()
    window.show()
    sys.exit(app.exec_())
    os._exit(0)
