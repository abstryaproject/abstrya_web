-- site_schema.sql
CREATE DATABASE IF NOT EXISTS abstryacloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE abstryacloud;

-- Pages (home, about, faq, support, etc)
CREATE TABLE IF NOT EXISTS pages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(255) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  content LONGTEXT NOT NULL,
  status ENUM('published','draft') DEFAULT 'published',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

-- Posts (blog merged into site)
CREATE TABLE IF NOT EXISTS posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(255) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  excerpt TEXT,
  content LONGTEXT NOT NULL,
  author VARCHAR(150),
  status ENUM('published','draft') DEFAULT 'draft',
  allow_comments TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP
);

-- Comments (tied to posts)
CREATE TABLE IF NOT EXISTS comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_email VARCHAR(255) NULL,
  user_name VARCHAR(150) NULL,
  user_keystone_id VARCHAR(64) NULL, -- stores Keystone user id for member role
  body TEXT NOT NULL,
  status ENUM('approved','pending','spam') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

-- Platform settings (key-value)
CREATE TABLE IF NOT EXISTS settings (
  `key` VARCHAR(128) PRIMARY KEY,
  `value` TEXT
);

-- Navigation (ordered)
CREATE TABLE IF NOT EXISTS navigation (
  id INT AUTO_INCREMENT PRIMARY KEY,
  label VARCHAR(128),
  href VARCHAR(255),
  `order` INT DEFAULT 0,
  visible TINYINT(1) DEFAULT 1
);
-- ===============================
-- Table for Frequently Asked Questions
-- ===============================
CREATE TABLE faqs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question VARCHAR(255) NOT NULL,
  answer TEXT NOT NULL,
  status ENUM('draft','published') DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- Table for Support Information
-- (single row or editable in admin)
-- ===============================
CREATE TABLE support_info (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  hours VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default support info (you can update later in admin)
INSERT INTO support_info (email, phone, hours) 
VALUES ('support@abstryacloud.local', '+234 800 123 4567', '24/7');

-- ===============================
-- Table for Contact Messages
-- ===============================
CREATE TABLE contact_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  subject VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  status ENUM('open','closed') DEFAULT 'open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE history (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user VARCHAR(100) NOT NULL,
  activity TEXT NOT NULL,
  day VARCHAR(20) NOT NULL,
  date DATE NOT NULL,
  time TIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE docs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- ===============================
-- Insert Platform Settings
-- ===============================
INSERT INTO settings (`key`, `value`) VALUES
('site_name', 'Abstrya Cloud ☁️'),
('theme', 'light'),
('banner_text', 'Welcome to Abstrya Cloud ☁️ - Enterprise Cloud Hosting'),
('footer_text', '&copy; 2025 Abstrya Cloud ☁️. All rights reserved.'),
('default_domain', 'abstryacloud.local');

-- ===============================
-- Insert Navigation Items
-- ===============================
INSERT INTO navigation (label, href, `order`, visible) VALUES
('Home', 'index.php', 1, 1),
('About', 'about.php', 2, 1),
('Blog', 'blog.php', 3, 1),
('FAQs', 'faq.php', 4, 1),
('Support', 'support.php', 5, 1),
('Contact', 'contact.php', 6, 1),
('Start Cloud', 'start.php', 7, 1);

-- ===============================
-- Insert Home Page
-- ===============================
INSERT INTO pages (slug, title, content, status) VALUES
('home', 'Welcome to Abstrya Cloud ☁️',
'<section class="hero">
  <h1>Welcome to Abstrya Cloud ☁️</h1>
  <p>Your trusted cloud platform with enterprise-grade reliability and security.</p>
  <a href="https://console.abstryacloud.local/" class="btn">Access now!</a>
</section>
<section class="container">
  <h2>Why Abstrya Cloud?</h2>
  <p>Experience secure, scalable, and reliable cloud hosting. Abstrya Cloud provides enterprises and developers all the tools needed to deploy applications and manage workloads efficiently.</p>
  <center><a href="/docs.php" class="btn">Read More &#10095;&#10095;</a></center>
</section>
<section class="container">
  <h2>Testimonials</h2>
  <div class="carousel" id="testimonialCarousel">
    <div class="carousel-item show">
      <p>&quot;Abstrya Cloud transformed our hosting experience. Fast, reliable, and secure!&quot;</p>
      <strong>- A.I. Lailaba, CTO</strong>
    </div>
    <div class="carousel-item">
      <p>&quot;The support team helped us migrate workloads seamlessly.&quot;</p>
      <strong>- David Smith, CEO</strong>
    </div>
    <div class="carousel-item">
      <p>&quot;Scalable infrastructure and easy-to-use dashboard. Highly recommend!&quot;</p>
      <strong> - Maria Lopez, DevOps Lead</strong>
    </div>
  </div>
</section>
<section class="container">
  <h2>Key Features</h2>
  <ul>
    <li>🔒 Enterprise-grade security</li>
    <li>⚡ High-performance virtual machines & containers</li>
    <li>🌐 Global scalability</li>
    <li>📈 Monitoring & analytics tools</li>
    <li>💼 Dedicated support & SLA-backed uptime</li>
    <li>💾 Automated backups & disaster recovery</li>
    <li>🛠 Developer-friendly APIs & automation tools</li>
  </ul>
</section>
<footer class="container">
  &copy; 2025 Abstrya Cloud ☁️. All rights reserved.
</footer>',
'published');

-- ===============================
-- Insert Sample FAQs
-- ===============================
INSERT INTO faqs (question, answer, status) VALUES
('How do I sign up?', 'Click the Get Started button on the home page and fill the registration form.', 'published'),
('Can I migrate my existing website?', 'Yes. Our support team will assist in migrating your workloads with zero downtime.', 'published'),
('Is SSL included?', 'All hosting plans come with free Let\'s Encrypt SSL certificates for your domains.', 'published');

-- ===============================
-- Insert Sample Blog Posts
-- ===============================
INSERT INTO posts (slug, title, excerpt, content, author, status, allow_comments) VALUES
('welcome-abstrya', 'Welcome to Abstrya Cloud ☁️', 'Introduction to our cloud platform.', 'Abstrya Cloud ☁️ provides secure and scalable cloud hosting for businesses of all sizes.', 'Admin', 'published', 1),
('high-performance-cloud', 'High Performance Cloud Infrastructure', 'Learn about our high-performance cloud.', 'Our platform delivers top-notch performance with virtual machines and containerized workloads.', 'Admin', 'published', 1);

-- ===============================
-- Insert Sample Documentation
-- ===============================
INSERT INTO docs (title, slug, content) VALUES
('Getting Started', 'getting-started', 'Step-by-step guide to start using Abstrya Cloud ☁️.'),
('Platform Overview', 'platform-overview', 'Learn about features and architecture of Abstrya Cloud ☁️.'),
('Account Management', 'account-management', 'Instructions on creating and managing user accounts.'),
('Security Guidelines', 'security-guidelines', 'Best practices to secure your workloads and data.');

-- ===============================
-- Insert Admin History Example
-- ===============================
INSERT INTO history (user, activity, day, date, time) VALUES
('admin', 'Created Home page', 'Monday', CURDATE(), CURTIME()),
('admin', 'Inserted sample blog posts', 'Monday', CURDATE(), CURTIME()),
('admin', 'Inserted sample FAQ entries', 'Monday', CURDATE(), CURTIME());