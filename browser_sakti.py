import sys
import os
os.environ["QTWEBENGINE_DISABLE_SANDBOX"] = "1"
from PyQt6.QtCore import QUrl, Qt
from PyQt6.QtWidgets import QApplication, QMainWindow, QToolBar, QLineEdit, QFileDialog
from PyQt6.QtWebEngineWidgets import QWebEngineView
from PyQt6.QtGui import QAction

app = QApplication(sys.argv)
app.setApplicationName("BrowserSakti") # KTP Digital

class BrowserSakti(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("APLIKASI_BROWSER")
        self.browser = QWebEngineView()
        self.browser.setUrl(QUrl("https://www.google.com"))
        self.setCentralWidget(self.browser)
        self.showMaximized()

        navbar = QToolBar()
        self.addToolBar(navbar)
        exit_btn = QAction('🏠 KELUAR', self); exit_btn.triggered.connect(self.close); navbar.addAction(exit_btn)
        home_btn = QAction('🔄 BERANDA', self); home_btn.triggered.connect(lambda: self.browser.setUrl(QUrl("https://www.google.com"))); navbar.addAction(home_btn)
        open_file_btn = QAction('📂 BUKA BERKAS', self); open_file_btn.triggered.connect(self.open_local_file); navbar.addAction(open_file_btn)
        self.url_bar = QLineEdit()
        self.url_bar.returnPressed.connect(self.navigate_to_url); navbar.addWidget(self.url_bar)
        self.browser.urlChanged.connect(lambda q: self.url_bar.setText(q.toString()))

    def open_local_file(self):
        file_path, _ = QFileDialog.getOpenFileName(self, "Pilih Berkas", "/home/kioskuser", "Semua Berkas (*)")
        if file_path: self.browser.setUrl(QUrl.fromLocalFile(file_path))

    def navigate_to_url(self):
        url = self.url_bar.text()
        if not url.startswith(('http', 'file')): url = 'https://' + url
        self.browser.setUrl(QUrl(url))

window = BrowserSakti()
sys.exit(app.exec())
