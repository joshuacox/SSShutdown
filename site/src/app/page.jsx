export default function HomePage() {
  return (
    <div className="container">
      {/* Hero */}
      <section className="hero">
        <div className="pill-tag">Safe Muscle Memory for Linux Sysadmins</div>
        <h1>Never Accidentally Power Off Remote Servers Again</h1>
        <p>
          SSShutdown abstracts system shutdown, rebooting, package updates, and CPU frequency management
          behind intentional, distinctive commands so you never accidentally shut down a production host.
        </p>
        <div className="cta-group">
          <a href="#installation" className="btn-primary">
            Quick Installation
          </a>
          <a href="#commands" className="btn-secondary">
            Command Documentation
          </a>
        </div>
      </section>

      {/* Responsive AdSense Placement Top */}
      <div className="ad-container">
        <div className="ad-label">Advertisement</div>
        <ins
          className="adsbygoogle"
          style={{ display: 'block' }}
          data-ad-client="ca-pub-8973108060277483"
          data-ad-slot="default"
          data-ad-format="auto"
          data-full-width-responsive="true"
        />
      </div>

      {/* Why SSShutdown */}
      <section id="philosophy">
        <h2 className="section-title">The Philosophy</h2>
        <p className="section-desc">
          Building safe habits through muscle memory reconditioning.
        </p>
        <div className="card">
          <p style={{ fontSize: '1.05rem', lineHeight: '1.75' }}>
            Typing <code>poweroff</code>, <code>shutdown -h now</code>, or <code>reboot</code> into a terminal
            comes naturally when wrapping up your workday on your local workstation. But if an SSH session
            to an offsite production cluster is still active in another tmux pane or window, that same muscle
            memory can bring down critical infrastructure.
          </p>
          <div className="callout" style={{ marginTop: '16px' }}>
            <strong>The Fail-Safe Mechanism:</strong> By exclusively training your fingers to use distinctive
            commands like <code>SSShutdown</code>, <code>RRReboot</code>, and <code>UUUpdateAndShutdown</code>,
            running them by mistake on a remote server safely triggers an innocuous{' '}
            <code>command not found</code> error.
          </div>
        </div>
      </section>

      {/* Commands Section */}
      <section id="commands">
        <h2 className="section-title">Command Reference</h2>
        <p className="section-desc">
          Every command is streamlined for speed, safety, and operational awareness.
        </p>

        <h3 style={{ margin: '24px 0 12px', color: '#fff' }}>Power & System State</h3>
        <div className="grid-3">
          <div className="card">
            <h4 className="card-title"><code>SSShutdown</code></h4>
            <p>Unceremoniously powers off the local machine via <code>sudo poweroff</code>.</p>
          </div>
          <div className="card">
            <h4 className="card-title"><code>RRReboot</code></h4>
            <p>Unceremoniously reboots the machine via <code>sudo reboot</code>.</p>
          </div>
          <div className="card">
            <h4 className="card-title"><code>sssuspend</code></h4>
            <p>Suspends the system to RAM using <code>systemctl suspend</code>.</p>
          </div>
          <div className="card">
            <h4 className="card-title"><code>hhhibernate</code></h4>
            <p>Verifies active swap before safely executing <code>systemctl hibernate</code>.</p>
          </div>
          <div className="card">
            <h4 className="card-title"><code>hybrid</code></h4>
            <p>Performs hybrid sleep state via <code>systemctl hybrid-sleep</code>.</p>
          </div>
        </div>

        <h3 style={{ margin: '36px 0 12px', color: '#fff' }}>Package Management & Updates</h3>
        <div className="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Command</th>
                <th>Ceremony?</th>
                <th>Description</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><code>UpdateOnly</code></td>
                <td>Yes</td>
                <td>Checks if updated in the past 24 hours. If older, updates all packages.</td>
              </tr>
              <tr>
                <td><code>UUUpdateAndShutdown</code></td>
                <td>Yes</td>
                <td>Runs ceremonial package updates; powers off only if updates succeed.</td>
              </tr>
              <tr>
                <td><code>MorningUpdate</code></td>
                <td>No (Forces)</td>
                <td>Clears update timestamps and forces a full system upgrade.</td>
              </tr>
              <tr>
                <td><code>FFForceUpdateAndShutdown</code></td>
                <td>No (Forces)</td>
                <td>Forces immediate upgrade and powers down on completion.</td>
              </tr>
              <tr>
                <td><code>mmmirrorUpdater</code></td>
                <td>Reflector</td>
                <td>Refreshes, tests, and sorts fastest regional package mirrors.</td>
              </tr>
              <tr>
                <td><code>CleanRing</code></td>
                <td>Recovery</td>
                <td>Universal GPG keyring repair for Arch, Debian/Ubuntu, and Red Hat/Fedora.</td>
              </tr>
              <tr>
                <td><code>ArchLinuxCleanRing</code></td>
                <td>Alias</td>
                <td>Backward-compatible alias pointing to <code>CleanRing</code>.</td>
              </tr>
            </tbody>
          </table>
        </div>

        <h3 style={{ margin: '36px 0 12px', color: '#fff' }}>CPU & Energy Governors</h3>
        <div className="grid-2">
          <div className="card">
            <h4 className="card-title"><code>Performance</code></h4>
            <p>Sets CPU governor to <code>performance</code> and clocks all cores to maximum rated frequency.</p>
          </div>
          <div className="card">
            <h4 className="card-title"><code>PowerSave</code></h4>
            <p>Locks CPUs to minimum frequency and automatically triggers <code>powertop --auto-tune</code>.</p>
          </div>
          <div className="card">
            <h4 className="card-title"><code>Mid</code></h4>
            <p>Limits CPU clocks to 50% max frequency under powersave governor to reduce fan noise.</p>
          </div>
          <div className="card">
            <h4 className="card-title"><code>Low</code></h4>
            <p>Caps CPU clocks to 25% max frequency for extreme battery preservation.</p>
          </div>
        </div>
      </section>

      {/* Ceremony Explained */}
      <section id="ceremony">
        <h2 className="section-title">The Ceremony</h2>
        <p className="section-desc">
          Intelligent caching prevents wasteful daily bandwidth consumption.
        </p>
        <div className="card">
          <p>
            Running full repository syncs multiple times a day strains package mirrors and wastes bandwidth.
            SSShutdown introduces <strong>Ceremony</strong>: checking marker files in <code>/root/.updated</code>{' '}
            and <code>/var/cache/pacman/</code> using POSIX timestamp differentials.
          </p>
          <div className="code-block">
            {`# Default interval checks:\nSYSTEM_UPDATE_INTERVAL=1      # days before repeating system upgrade\nMIRROR_UPDATE_INTERVAL=7      # days before re-ranking mirrors\nSYSTEM_CLEARCACHE_INTERVAL=30 # days before purging stale package caches`}
          </div>
          <p style={{ marginTop: '12px' }}>
            If the system was already upgraded within the threshold interval, SSShutdown gracefully skips the
            redundant operation and proceeds immediately.
          </p>
        </div>
      </section>

      {/* Supported Distributions */}
      <section id="distros">
        <h2 className="section-title">Multi-Distribution Support</h2>
        <p className="section-desc">
          Detects system metadata from <code>/etc/os-release</code> and routes to the native package manager.
        </p>
        <div className="grid-3">
          <div className="card">
            <h4 className="card-title">Arch & Omarchy</h4>
            <p>Native <code>pacman</code>, <code>reflector</code>, <code>powerpill</code>, and <code>paccache</code> automated cleaning.</p>
          </div>
          <div className="card">
            <h4 className="card-title">Debian & Ubuntu</h4>
            <p>Non-interactive <code>apt-get</code> with dpkg lock checking, automated <code>autoremove</code>, and reboot alerts.</p>
          </div>
          <div className="card">
            <h4 className="card-title">Red Hat & Fedora</h4>
            <p>Robust <code>dnf</code>/<code>yum</code>/<code>microdnf</code> upgrades, lock checks, RPM key recovery, and <code>needs-restarting</code>.</p>
          </div>
          <div className="card">
            <h4 className="card-title">openSUSE</h4>
            <p>Reliable <code>zypper -n update</code> operations with ceremony caching.</p>
          </div>
          <div className="card">
            <h4 className="card-title">NixOS</h4>
            <p>Native integration with Nix auto updates (<code>nx auto -f</code>).</p>
          </div>
          <div className="card">
            <h4 className="card-title">Lifecycle Hooks</h4>
            <p>Universal pre/post execution hooks via <code>/etc/ssshutdown/hooks/in</code> and <code>out</code> across all distros.</p>
          </div>
        </div>
      </section>

      {/* Responsive AdSense Placement Middle */}
      <div className="ad-container">
        <div className="ad-label">Advertisement</div>
        <ins
          className="adsbygoogle"
          style={{ display: 'block' }}
          data-ad-client="ca-pub-8973108060277483"
          data-ad-slot="default"
          data-ad-format="auto"
          data-full-width-responsive="true"
        />
      </div>

      {/* Installation */}
      <section id="installation">
        <h2 className="section-title">Installation</h2>
        <p className="section-desc">
          Get up and running in seconds on any Linux distribution.
        </p>

        <h3 style={{ margin: '20px 0 10px', color: '#fff' }}>Automated One-Liner</h3>
        <div className="code-block">
          curl -sL https://raw.githubusercontent.com/joshuacox/SSShutdown/master/bootstrap | bash
        </div>

        <h3 style={{ margin: '24px 0 10px', color: '#fff' }}>Traditional Makefile</h3>
        <div className="code-block">
          {`git clone https://github.com/joshuacox/SSShutdown.git\ncd SSShutdown\nsudo make install`}
        </div>

        <h3 style={{ margin: '24px 0 10px', color: '#fff' }}>Custom Target Prefix</h3>
        <div className="code-block">
          PREFIX=/opt make -e install
        </div>

        <h3 style={{ margin: '24px 0 10px', color: '#fff' }}>Nix Flake</h3>
        <div className="code-block">
          nix profile install github:joshuacox/SSShutdown
        </div>
      </section>

      {/* Configuration */}
      <section id="configuration">
        <h2 className="section-title">Environment Variables</h2>
        <p className="section-desc">
          Configure behavior dynamically without modifying files.
        </p>
        <div className="table-wrapper">
          <table>
            <thead>
              <tr>
                <th>Variable</th>
                <th>Default</th>
                <th>Purpose</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><code>REFLECTOR_COUNTRY</code></td>
                <td><code>US</code></td>
                <td>Country code passed to reflector for mirror filtering on Arch.</td>
              </tr>
              <tr>
                <td><code>APT_UPGRADE_TYPE</code></td>
                <td><code>upgrade</code></td>
                <td>Debian upgrade mode (<code>upgrade</code> or <code>dist-upgrade</code>).</td>
              </tr>
              <tr>
                <td><code>REDHAT_PKG_MGR</code></td>
                <td>Auto</td>
                <td>Override package manager on Red Hat systems (<code>dnf</code>, <code>yum</code>, <code>microdnf</code>).</td>
              </tr>
              <tr>
                <td><code>SYSTEM_UPDATE_INTERVAL</code></td>
                <td><code>1</code></td>
                <td>Number of days before performing a ceremony update.</td>
              </tr>
              <tr>
                <td><code>MIRROR_UPDATE_INTERVAL</code></td>
                <td><code>7</code></td>
                <td>Days between mirror ranking cycles.</td>
              </tr>
              <tr>
                <td><code>SYSTEM_CLEARCACHE_INTERVAL</code></td>
                <td><code>30</code></td>
                <td>Days between running cache cleanup (paccache, apt autoremove, dnf clean).</td>
              </tr>
              <tr>
                <td><code>PACMAN_LOOPER</code></td>
                <td><code>true</code></td>
                <td>Retries update loop up to 10 times if keyrings require refresh.</td>
              </tr>
              <tr>
                <td><code>USE_POWERPILL</code></td>
                <td><code>false</code></td>
                <td>Accelerates downloads using parallel segmented powerpill.</td>
              </tr>
              <tr>
                <td><code>DEBUG</code></td>
                <td><code>false</code></td>
                <td>Enables <code>set -x</code> debugging output across all scripts.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      {/* Bottom Ad Container */}
      <div className="ad-container">
        <div className="ad-label">Advertisement</div>
        <ins
          className="adsbygoogle"
          style={{ display: 'block' }}
          data-ad-client="ca-pub-8973108060277483"
          data-ad-slot="default"
          data-ad-format="auto"
          data-full-width-responsive="true"
        />
      </div>
    </div>
  );
}
