# Module to specify config vars for DocFetch

import sys
import os.path
import xml.etree.ElementTree as ET
import xmlutil

Configpath = '~/.local/share/applications/DocFetch'
Configroot = "DFConfig"

class DFConfigError(Exception):
    pass

def getconfigname(file):
    """Manufacture configuration name"""
    return os.path.abspath(os.path.expanduser(os.path.expandvars(file)))

class DFConfig(object):
    
    def __init__(self):
        self.username = ""
        self.password = ""
        self.cookiefile = ""
    
    def load(self, node):
        """Load from XML file"""
        self.username = ""
        self.password = ""
        self.cookiefile = ""
        for child in node:
            tagn = child.tag
            if tagn == "username":
                self.username = xmlutil.gettext(child)
            elif tagn == "password":
                self.password = xmlutil.gettext(child)
            elif tagn == "cookiefile":
                self.cookiefile = xmlutil.gettext(child)

    def save(self, doc, pnode, name):
        """Save to XML file"""
        node = ET.SubElement(pnode, name)
        if len(self.username) != 0: xmlutil.savedata(doc, node, "username", self.username)
        if len(self.password) != 0: xmlutil.savedata(doc, node, "password", self.password)
        if len(self.cookiefile) != 0: xmlutil.savedata(doc, node, "cookiefile", self.cookiefile)
    
    def loadfile(self, filename = Configpath, rootname = Configroot):
        """Load a config file"""
        try:
            doc, root = xmlutil.load_file(filename, rootname)
            cdata = xmlutil.find_child(root, "cdata")
            self.load(cdata)
        except xmlutil.XMLError:
            pass
    
    def savefile(self, filename = Configpath, rootname = Configroot):
        """Save a config name"""
        doc, root = xmlutil.init_save(rootname, rootname)
        self.save(doc, root, "cdata")
        try:
            xmlutil.complete_save(getconfigname(filename), doc)
        except XMLError as e:
            raise DFConfigError(*e.args)
    