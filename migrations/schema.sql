-- ============================================
-- LABORATORIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS laboratories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL UNIQUE,
  code VARCHAR(50) UNIQUE,
  address TEXT,
  city VARCHAR(100),
  country VARCHAR(100),
  zip_code VARCHAR(20),
  phone VARCHAR(20),
  email VARCHAR(100) UNIQUE,
  website VARCHAR(255),
  manager_name VARCHAR(255),
  license_number VARCHAR(100) UNIQUE,
  accreditation_status ENUM('pending', 'approved', 'rejected', 'expired') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_name (name),
  INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  role ENUM('admin', 'manager', 'technician', 'analyst', 'viewer') DEFAULT 'viewer',
  department VARCHAR(100),
  phone VARCHAR(20),
  avatar_url VARCHAR(255),
  is_active BOOLEAN DEFAULT true,
  totp_secret VARCHAR(255),
  totp_enabled BOOLEAN DEFAULT false,
  backup_codes JSON,
  last_login DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  INDEX idx_laboratory (laboratory_id),
  INDEX idx_email (email),
  INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- CLIENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS clients (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(100) NOT NULL,
  contact_person VARCHAR(255),
  email VARCHAR(100),
  phone VARCHAR(20),
  address TEXT,
  city VARCHAR(100),
  zip_code VARCHAR(20),
  country VARCHAR(100),
  industry_type VARCHAR(100),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  UNIQUE KEY unique_client (laboratory_id, code),
  INDEX idx_laboratory (laboratory_id),
  INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SAMPLE TYPES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS sample_types (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  UNIQUE KEY unique_type (laboratory_id, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SAMPLES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS samples (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  client_id INT NOT NULL,
  sample_code VARCHAR(100) NOT NULL UNIQUE,
  sample_type_id INT,
  description TEXT,
  quantity DECIMAL(10, 2),
  unit VARCHAR(50),
  status ENUM('received', 'processing', 'completed', 'rejected', 'archived') DEFAULT 'received',
  received_date DATETIME NOT NULL,
  expected_completion_date DATETIME,
  completed_date DATETIME,
  stored_location VARCHAR(100),
  storage_temperature VARCHAR(50),
  preservation_method VARCHAR(100),
  rejection_reason TEXT,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
  FOREIGN KEY (sample_type_id) REFERENCES sample_types(id),
  FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_laboratory (laboratory_id),
  INDEX idx_client (client_id),
  INDEX idx_status (status),
  INDEX idx_sample_code (sample_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ANALYSIS SERVICES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS analysis_services (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(100) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  method VARCHAR(255),
  unit_of_measurement VARCHAR(50),
  minimum_detectable_level DECIMAL(12, 4),
  maximum_quantifiable_level DECIMAL(12, 4),
  reference_values JSON,
  turnaround_time_days INT,
  price DECIMAL(10, 2),
  is_active BOOLEAN DEFAULT true,
  requires_instrument BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  UNIQUE KEY unique_service (laboratory_id, code),
  INDEX idx_laboratory (laboratory_id),
  INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ANALYSIS REQUESTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS analysis_requests (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  sample_id INT NOT NULL,
  analysis_service_id INT NOT NULL,
  request_number VARCHAR(100) NOT NULL UNIQUE,
  status ENUM('pending', 'in_progress', 'completed', 'approved', 'rejected') DEFAULT 'pending',
  priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  assigned_to INT,
  start_date DATETIME,
  completion_date DATETIME,
  approved_by INT,
  approval_date DATETIME,
  rejection_reason TEXT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  FOREIGN KEY (sample_id) REFERENCES samples(id) ON DELETE CASCADE,
  FOREIGN KEY (analysis_service_id) REFERENCES analysis_services(id),
  FOREIGN KEY (assigned_to) REFERENCES users(id),
  FOREIGN KEY (approved_by) REFERENCES users(id),
  INDEX idx_laboratory (laboratory_id),
  INDEX idx_status (status),
  INDEX idx_sample (sample_id),
  INDEX idx_request_number (request_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ANALYSIS RESULTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS analysis_results (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  analysis_request_id INT NOT NULL,
  raw_value DECIMAL(12, 4),
  calculated_value DECIMAL(12, 4),
  unit_value VARCHAR(50),
  detection_status ENUM('detected', 'not_detected', 'out_of_range', 'valid') DEFAULT 'valid',
  is_result_within_range BOOLEAN,
  lower_limit DECIMAL(12, 4),
  upper_limit DECIMAL(12, 4),
  remarks TEXT,
  quality_flag VARCHAR(50),
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  FOREIGN KEY (analysis_request_id) REFERENCES analysis_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_laboratory (laboratory_id),
  INDEX idx_analysis_request (analysis_request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- INSTRUMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS instruments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(100) NOT NULL UNIQUE,
  type VARCHAR(100),
  model VARCHAR(100),
  manufacturer VARCHAR(100),
  serial_number VARCHAR(100),
  purchase_date DATE,
  purchase_price DECIMAL(12, 2),
  last_calibration_date DATE,
  next_calibration_date DATE,
  calibration_frequency_days INT,
  status ENUM('active', 'maintenance', 'inactive', 'decommissioned') DEFAULT 'active',
  location VARCHAR(100),
  responsible_person INT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  FOREIGN KEY (responsible_person) REFERENCES users(id),
  INDEX idx_laboratory (laboratory_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- INSTRUMENT MAINTENANCE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS instrument_maintenance (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  instrument_id INT NOT NULL,
  maintenance_type ENUM('preventive', 'corrective', 'calibration') DEFAULT 'preventive',
  maintenance_date DATETIME NOT NULL,
  description TEXT,
  performed_by INT,
  vendor_name VARCHAR(255),
  cost DECIMAL(10, 2),
  next_maintenance_date DATE,
  status ENUM('scheduled', 'in_progress', 'completed', 'cancelled') DEFAULT 'scheduled',
  completion_date DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  FOREIGN KEY (instrument_id) REFERENCES instruments(id) ON DELETE CASCADE,
  FOREIGN KEY (performed_by) REFERENCES users(id),
  INDEX idx_laboratory (laboratory_id),
  INDEX idx_instrument (instrument_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- REPORTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS reports (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  sample_id INT NOT NULL,
  report_number VARCHAR(100) NOT NULL UNIQUE,
  title VARCHAR(255),
  generated_by INT NOT NULL,
  report_data LONGTEXT,
  status ENUM('draft', 'pending_approval', 'approved', 'signed', 'archived') DEFAULT 'draft',
  approved_by INT,
  approval_date DATETIME,
  signed_by INT,
  signed_date DATETIME,
  issued_date DATETIME,
  validity_period_days INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  FOREIGN KEY (sample_id) REFERENCES samples(id) ON DELETE CASCADE,
  FOREIGN KEY (generated_by) REFERENCES users(id),
  FOREIGN KEY (approved_by) REFERENCES users(id),
  FOREIGN KEY (signed_by) REFERENCES users(id),
  INDEX idx_laboratory (laboratory_id),
  INDEX idx_sample (sample_id),
  INDEX idx_status (status),
  INDEX idx_report_number (report_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- AUDIT LOGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  user_id INT,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(100),
  entity_id INT,
  old_values JSON,
  new_values JSON,
  ip_address VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_created_at (created_at),
  INDEX idx_user_id (user_id),
  INDEX idx_laboratory (laboratory_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- QUALITY CONTROL TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS quality_control (
  id INT PRIMARY KEY AUTO_INCREMENT,
  laboratory_id INT NOT NULL,
  analysis_request_id INT NOT NULL,
  control_type ENUM('blank', 'positive', 'negative', 'duplicate', 'reference') DEFAULT 'blank',
  control_value DECIMAL(12, 4),
  acceptable_range_min DECIMAL(12, 4),
  acceptable_range_max DECIMAL(12, 4),
  status ENUM('passed', 'failed', 'pending') DEFAULT 'pending',
  remarks TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (laboratory_id) REFERENCES laboratories(id) ON DELETE CASCADE,
  FOREIGN KEY (analysis_request_id) REFERENCES analysis_requests(id),
  INDEX idx_laboratory (laboratory_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
