# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'fetchconfdlg.ui'
#
# Created: Wed Dec 17 22:16:08 2014
#      by: PyQt4 UI code generator 4.10.4
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    def _fromUtf8(s):
        return s

try:
    _encoding = QtGui.QApplication.UnicodeUTF8
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)
except AttributeError:
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)

class Ui_fetchconfdlg(object):
    def setupUi(self, fetchconfdlg):
        fetchconfdlg.setObjectName(_fromUtf8("fetchconfdlg"))
        fetchconfdlg.resize(527, 282)
        self.buttonBox = QtGui.QDialogButtonBox(fetchconfdlg)
        self.buttonBox.setGeometry(QtCore.QRect(160, 220, 341, 32))
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.label = QtGui.QLabel(fetchconfdlg)
        self.label.setGeometry(QtCore.QRect(40, 20, 121, 18))
        self.label.setObjectName(_fromUtf8("label"))
        self.username = QtGui.QLineEdit(fetchconfdlg)
        self.username.setGeometry(QtCore.QRect(170, 20, 321, 30))
        self.username.setObjectName(_fromUtf8("username"))
        self.label_2 = QtGui.QLabel(fetchconfdlg)
        self.label_2.setGeometry(QtCore.QRect(40, 60, 101, 18))
        self.label_2.setObjectName(_fromUtf8("label_2"))
        self.password = QtGui.QLineEdit(fetchconfdlg)
        self.password.setGeometry(QtCore.QRect(170, 60, 321, 30))
        self.password.setEchoMode(QtGui.QLineEdit.Password)
        self.password.setObjectName(_fromUtf8("password"))
        self.label_3 = QtGui.QLabel(fetchconfdlg)
        self.label_3.setGeometry(QtCore.QRect(40, 110, 111, 18))
        self.label_3.setObjectName(_fromUtf8("label_3"))
        self.cookiefile = QtGui.QLineEdit(fetchconfdlg)
        self.cookiefile.setGeometry(QtCore.QRect(170, 110, 321, 30))
        self.cookiefile.setObjectName(_fromUtf8("cookiefile"))
        self.selectcookie = QtGui.QPushButton(fetchconfdlg)
        self.selectcookie.setGeometry(QtCore.QRect(390, 160, 105, 28))
        self.selectcookie.setObjectName(_fromUtf8("selectcookie"))
        self.label.setBuddy(self.username)
        self.label_2.setBuddy(self.password)
        self.label_3.setBuddy(self.cookiefile)

        self.retranslateUi(fetchconfdlg)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), fetchconfdlg.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), fetchconfdlg.reject)
        QtCore.QMetaObject.connectSlotsByName(fetchconfdlg)
        fetchconfdlg.setTabOrder(self.username, self.password)
        fetchconfdlg.setTabOrder(self.password, self.cookiefile)
        fetchconfdlg.setTabOrder(self.cookiefile, self.selectcookie)
        fetchconfdlg.setTabOrder(self.selectcookie, self.buttonBox)

    def retranslateUi(self, fetchconfdlg):
        fetchconfdlg.setWindowTitle(_translate("fetchconfdlg", "Set DocFetch config", None))
        self.label.setText(_translate("fetchconfdlg", "&ADS Username", None))
        self.username.setToolTip(_translate("fetchconfdlg", "This is the user name to log into ADS with", None))
        self.label_2.setText(_translate("fetchconfdlg", "&Password", None))
        self.password.setToolTip(_translate("fetchconfdlg", "<html><head/><body><p>This is the ADS password</p></body></html>", None))
        self.label_3.setText(_translate("fetchconfdlg", "&Saved cookies", None))
        self.cookiefile.setToolTip(_translate("fetchconfdlg", "<html><head/><body><p>This is where cookies get saved.</p></body></html>", None))
        self.selectcookie.setToolTip(_translate("fetchconfdlg", "Click to select a cookie file", None))
        self.selectcookie.setText(_translate("fetchconfdlg", "Select", None))

