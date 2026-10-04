import './globals.css';

export const metadata = {
  title: 'SSShutdown - Safe Linux Power Management & Package Updates',
  description: 'Abstract shutdown, reboot, and update commands to build safe muscle memory and protect remote servers.',
  viewport: 'width=device-width, initial-scale=1',
  other: {
    'google-adsense-account': 'ca-pub-8973108060277483',
  },
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <head>
        <script
          async
          src="https://pagead2.googlesyndicationv2.com/pagead/js/adsbygoogle.js?client=ca-pub-8973108060277483"
          crossOrigin="anonymous"
        />
      </head>
      <body>
        <header>
          <div className="container header-content">
            <a href="#" className="logo-badge">
              <span className="logo-icon">SS</span>
              <span>SSShutdown</span>
            </a>
            <nav>
              <ul className="nav-links">
                <li><a href="#commands">Commands</a></li>
                <li><a href="#ceremony">Ceremony</a></li>
                <li><a href="#installation">Installation</a></li>
                <li><a href="#configuration">Configuration</a></li>
                <li>
                  <a
                    href="https://github.com/joshuacox/SSShutdown"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    GitHub
                  </a>
                </li>
              </ul>
            </nav>
          </div>
        </header>

        <main>{children}</main>

        <footer>
          <div className="container">
            <p>
              SSShutdown — Safe Linux power and package management. Open source under the GPL-3.0 License.
            </p>
          </div>
        </footer>
      </body>
    </html>
  );
}
