#! /usr/bin/env python

import sys
from PyQt4.QtCore import *
from PyQt4.QtGui import *

import ui_fetchconfdlg
import dfconfig

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

config = dfconfig.DFConfig()
config.loadfile()
dlg = fetchconfigdlg()
dlg.username.setText(config.username)
dlg.password.setText(config.password)
dlg.cookiefile.setText(config.cookiefile)

if dlg.exec_():
    try:
        config.username = str(dlg.username.text())
        config.password = str(dlg.password.text())
        config.cookiefile = str(dlg.cookiefile.text())
        config.savefile()
    except dfconfig.DFConfigError as e:
        print "Error saving config", e.args[0]
        sys.exit(200)
    sys.exit(0)
else:
    sys.exit(100)
