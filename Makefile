#
# Generated Makefile for PyQt interfaces
#
# Created on Wed Dec 17 18:41:31 2014

all:	ui_fetchconfdlg.py

ui_fetchconfdlg.py:	fetchconfdlg.ui
	pyuic4 -o $@ $?

clean:
	rm -f ui_*.py *_rc.py *.pyc

distclean: clean
	rm -f config.py
