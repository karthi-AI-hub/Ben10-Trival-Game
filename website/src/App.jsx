import React, { useEffect, useState } from 'react';
import { Routes, Route, Link, useLocation } from 'react-router-dom';
import './App.css';

// SEO Helper Hook
const useSEO = (title, description) => {
  useEffect(() => {
    document.title = title;
    const metaDesc = document.querySelector('meta[name="description"]');
    if (metaDesc) metaDesc.setAttribute('content', description);
  }, [title, description]);
};

function App() {
  const { pathname } = useLocation();
  const [loading, setLoading] = useState(true);
  const [heroIndex, setHeroIndex] = useState(0);
  const [showcaseIndex, setShowcaseIndex] = useState(0);

  const heroImages = [
    { src: "/classic_ben.png", class: "c1", alt: "Classic Ben" },
    { src: "/af_ben.png", class: "c2", alt: "Alien Force Ben" },
    { src: "/ua_ben.png", class: "c3", alt: "Ultimate Alien Ben" },
    { src: "/ov_ben.png", class: "c4", alt: "Omniverse Ben" }
  ];

  const showcaseImages = [
    { src: "/image1.jpg", alt: "Interface 1" },
    { src: "/image2.jpg", alt: "Interface 2" },
    { src: "/image3.jpg", alt: "Interface 3" },
    { src: "/image4.jpg", alt: "Interface 4" }
  ];

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [pathname]);

  useEffect(() => {
    const timer = setTimeout(() => setLoading(false), 2500);
    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    const heroInterval = setInterval(() => {
      setHeroIndex((prev) => (prev + 1) % heroImages.length);
    }, 2500);

    const showcaseInterval = setInterval(() => {
      setShowcaseIndex((prev) => (prev + 1) % showcaseImages.length);
    }, 3000);

    return () => {
      clearInterval(heroInterval);
      clearInterval(showcaseInterval);
    };
  }, [heroImages.length, showcaseImages.length]);

  if (loading) return <LoadingScreen />;

  return (
    <>
      <header className="header">
        <div className="container nav-content">
          <Link to="/" className="logo-area">
            <img src="/logo.webp" alt="Omnitrix Logo" className="logo-icon" />
            <span className="logo-text">BEN 10 TRIVIA</span>
          </Link>
          <nav className="nav-links">
            <a href="/#database" className="nav-link">Aliens</a>
            <a href="/#threats" className="nav-link">Threats</a>
            <a href="/#interface" className="nav-link">Interface</a>
            <Link to="/privacy" className="nav-link">Legal</Link>
          </nav>
          <button className="btn-primary">Initialize Check</button>
        </div>
      </header>

      <main>
        <Routes>
          <Route path="/" element={<Home heroIndex={heroIndex} heroImages={heroImages} showcaseIndex={showcaseIndex} showcaseImages={showcaseImages} />} />
          <Route path="/privacy" element={<LegalFrame title="PRIVACY POLICY" content={privacyContent} date="Effective Date: December 25, 2025" />} />
          <Route path="/terms" element={<LegalFrame title="TERMS OF SERVICE" content={termsContent} date="Last Updated: December 25, 2025" />} />
        </Routes>
      </main>

      <footer className="footer">
        <div className="container footer-grid">
          <div className="footer-brand">
            <h2>BEN 10 ULTIMATE TRIVIA</h2>
            <p className="footer-desc">The definitive knowledge base for Plumbers and galactic enforcers. <br /> Support: gamesnexera@gmail.com</p>
          </div>
          <div className="footer-azmuth">
            <img src="/azmuth.png" alt="Azmuth" className="azmuth-avatar" />
            <div className="azmuth-quote">"The Omnitrix was not intended for this... but you have exceeded my expectations."</div>
          </div>
          <div className="footer-bottom">
            <span>© 2025 Nexera Games. Fan Art Project.</span>
            <span>Not affiliated with Cartoon Network or Warner Bros. Discovery.</span>
            <div className="footer-legal-links">
              <Link to="/privacy">Privacy Policy</Link> | <Link to="/terms">Terms of Service</Link>
            </div>
          </div>
        </div>
      </footer>
    </>
  );
}

const Home = ({ heroIndex, heroImages }) => {
  useSEO("Ben 10 Ultimate Trivia | The Definitive Fan Experience", "Master the Omnitrix across 4 generations. The ultimate Ben 10 quiz game featuring high-fidelity data on over 80 aliens.");

  const showcaseImages = [
    "/image1.jpg", "/image2.jpg", "/image3.jpg", "/image4.jpg"
  ];

  return (
    <>
      <section className="hero">
        <div className="hero-bg-fx"></div>
        <div className="container hero-grid">
          <div className="hero-content animate-fade">
            <span className="hero-badge">BEN 10 ULTIMATE TRIVIA</span>
            <h1 className="hero-heading">
              <span className="glitch-wrapper">
                <span className="glitch-text" data-text="IT'S HERO TIME">IT'S HERO TIME</span>
              </span>
            </h1>
            <p className="hero-sub">
              Access the Omnitrix database. Verify your knowledge.
              From the streets of Bellwood to the Null Void, prove you are worthy of the watch.
            </p>
            <div className="hero-actions">
              <button className="btn-primary">Download App</button>
              <button className="btn-ghost">View Specs</button>
            </div>
          </div>
          <div className="hero-visual">
            <div className="omnitrix-hologram"></div>
            {/* Hero Composition - Auto Swapping Slider */}
            <div className="hero-squad">
              {heroImages.map((hero, index) => (
                <img
                  key={index}
                  src={hero.src}
                  alt={hero.alt}
                  className={`hero-ben ${hero.class} ${index === heroIndex ? 'active' : ''}`}
                />
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Feature / Stats Section */}
      <section id="mission" className="stats-section">
        <div className="container">
          <div className="stat-row">
            <div className="stat-item">
              <span className="stat-num">4</span>
              <span className="stat-label">GENERATIONS</span>
            </div>
            <div className="stat-item">
              <span className="stat-num">80+</span>
              <span className="stat-label">DNA SAMPLES</span>
            </div>
            <div className="stat-item">
              <span className="stat-num">100%</span>
              <span className="stat-label">ACCURACY</span>
            </div>
          </div>
        </div>
      </section>

      {/* Alien Database Grid */}
      <section id="database" className="features-section">
        <div className="container">
          <header className="section-header center">
            <span className="section-label">DNA Archive</span>
            <h2 className="section-title">Verified Transformations</h2>
            <p className="section-desc">Analyze the combat capabilities of the universe's most powerful species.</p>
          </header>

          <div className="alien-grid">
            <AlienCard name="Diamondhead" species="Petrosapien" img="/diamondhead_chromastone_rebirth.png" />
            <AlienCard name="Lodestar" species="Biosovortian" img="/lodestar.png" />
            <AlienCard name="Spidermonkey" species="Arachnichimp" img="/spidermonkey.png" />
            <AlienCard name="Nanomech" species="Nanochip" img="/nanomech.png" />
          </div>
        </div>
      </section>

      {/* Threats Section */}
      <section id="threats" className="threats-section">
        <div className="container">
          <header className="section-header">
            <span className="section-label red-alert">Threat Assessment</span>
            <h2 className="section-title">Galactic Enemies</h2>
          </header>
          <div className="villains-grid">
            <VillainCard
              name="Albedo"
              desc="Galvan geneticist. Creator of the Ultimatrix. Dangerous intellect."
              img="/albedo_ben_clone.png"
              color="red"
            />
            <VillainCard
              name="Highbreed"
              desc="Xenophobic conquerors. Extremely resilient and strong."
              img="/highbreed_transformation.png"
              color="purple"
            />
          </div>
        </div>
      </section>

      {/* Enhanced Showcase: Infinite Cinematic Marquee */}
      <section id="interface" className="showcase-cinematic">
        <div className="container center-text">
          <header className="section-header center">
            <span className="section-label">Omnitrix Interface</span>
            <h2 className="section-title">Holographic System</h2>
          </header>
        </div>
        <div className="marquee-wrapper">
          <div className="marquee-content">
            {[...showcaseImages, ...showcaseImages].map((img, i) => (
              <div key={i} className="marquee-item">
                <img src={img} alt={`Showcase ${i}`} />
                <div className="marquee-border"></div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </>
  );
};

const LoadingScreen = () => (
  <div className="loading-screen">
    <div className="loader-content">
      <img src="/loader.png" alt="Loading..." className="loader-img" />
      <div className="loader-bar">
        <div className="loader-progress"></div>
      </div>
      <p className="loader-text">INITIALIZING OMNITRIX CORE...</p>
      <span className="loader-sub">Verifying DNA Signatures</span>
    </div>
  </div>
);

const AlienCard = ({ name, species, img }) => (
  <div className="alien-card glass-panel">
    <div className="alien-img-container">
      <img src={img} alt={name} loading="lazy" />
    </div>
    <div className="alien-info">
      <h4>{name}</h4>
      <span className="species">{species}</span>
    </div>
  </div>
);

const VillainCard = ({ name, desc, img, color }) => (
  <div className={`villain-card ${color}`}>
    <div className="villain-content">
      <h3>{name}</h3>
      <p>{desc}</p>
    </div>
    <div className="villain-visual">
      <img src={img} alt={name} />
    </div>
  </div>
);

const LegalFrame = ({ title, content, date }) => {
  useSEO(`${title} | Ben 10 Ultimate Trivia`, title);
  return (
    <section className="container" style={{ paddingTop: '150px', paddingBottom: '100px' }}>
      <Link to="/" style={{ color: 'var(--primary)', marginBottom: '30px', display: 'inline-flex', alignItems: 'center', textDecoration: 'none' }}>
        &larr; <span style={{ marginLeft: '10px' }}>RETURN TO BASE</span>
      </Link>
      <div className="legal-header">
        <h1 style={{ fontSize: '3rem', marginBottom: '10px' }}>{title}</h1>
        <p style={{ color: '#666', marginBottom: '40px' }}>{date}</p>
      </div>
      <div className="glass-panel legal-content">
        {content.map((item, i) => (
          <div key={i} className="legal-block">
            <h3>{item.h}</h3>
            <p>{item.p}</p>
          </div>
        ))}
        <div className="legal-footer">
          <p>End of Document.</p>
        </div>
      </div>
    </section>
  )
};

// Professional Privacy Content
const privacyContent = [
  { h: "1. Introduction", p: "Welcome to Ben 10 Ultimate Trivia. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about this privacy notice, or our practices with regards to your personal information, please contact us." },
  { h: "2. Information We Collect", p: "We collect information that you voluntarily provide to us when you register on the App, express an interest in obtaining information about us or our products and Services, when you participate in activities on the App or otherwise when you contact us." },
  { h: "3. Device Data", p: "We automatically collect certain information when you visit, use or navigate the App. This information does not reveal your specific identity (like your name or contact information) but may include device and usage information, such as your IP address, browser and device characteristics, operating system, language preferences, referring URLs, device name, country, location, and other technical information." },
  { h: "4. Information Usage", p: "Pixels and Cookies: We may use cookies and similar tracking technologies (like web beacons and pixels) to access or store information. Specific information about how we use such technologies and how you can refuse certain cookies is set out in our Cookie Notice." },
  { h: "5. Third-Party Services", p: "We may allow selected third parties (such as Google AdMob) to use tracking technology on the App, which will enable them to collect data on our behalf about how you interact with our App over time. This information may be used to, among other things, analyze and track data, determine the popularity of certain content, pages or features, and better understand online activity." },
  { h: "6. Data Security", p: "We have implemented appropriate technical and organizational security measures designed to protect the security of any personal information we process. However, despite our safeguards and efforts to secure your information, no electronic transmission over the Internet or information storage technology can be guaranteed to be 100% secure." },
  { h: "7. Policy Updates", p: "We may update this privacy notice from time to time. The updated version will be indicated by an updated 'Revised' date and the updated version will be effective as soon as it is accessible." }
];

// Professional Terms Content
const termsContent = [
  { h: "1. Agreement to Terms", p: "By accessing or using our application, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, then you may not access the Service. Contact: gamesnexera@gmail.com" },
  { h: "2. Intellectual Property", p: "The Service and its original content (excluding Content provided by users), features and functionality are and will remain the exclusive property of Nexera Games. 'Ben 10' and all related characters and elements are trademarks of and © Cartoon Network. This application is a fan-made work and is not endorsed by or affiliated with Cartoon Network." },
  { h: "3. User Responsibilities", p: "You are responsible for your use of the Service and for any consequences thereof. You may use the Service only if you can form a binding contract with Nexera Games and are not a person barred from receiving services under the laws of the applicable jurisdiction." },
  { h: "4. Termination", p: "We may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms." },
  { h: "5. Limitation of Liability", p: "In no event shall Nexera Games, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service." },
  { h: "6. Changes", p: "We reserve the right, at our sole discretion, to modify or replace these Terms at any time. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms." },
  { h: "7. Contact Information", p: "If you have any questions about these Terms, please contact us at gamesnexera@gmail.com." }
];

export default App;
