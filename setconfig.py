#! /usr/bin/env python

import sys
from PyQt4.QtCore import *
from PyQt4.QtGui import *

import ui_fetchconfdlg

class fetchconfigdlg(QDialog, ui_fetchconfdlg.Ui_fetchconfdlg):

    def __init__(self, parent = None):
        super(fetchconfigdlg, self).__init__(parent)
        self.setupUi(self)

    def on_selectcookie_clicked(self, b = None):
        if b is None: return
        fname = QFileDialog.getOpenFileName(self, self.tr("Select cookie file"), self.cookiefile.text())
        if len(fname) == 0: return
        self.cookiefile.setText(fname)

app = QApplication(sys.argv)

dlg = fetchconfigdlg()

if dlg.exec_():
    print str(dlg.username.text())
    print str(dlg.password.text())
    print str(dlg.cookiefile.text())
    sys.exit(0)
else:
    sys.exit(100)
