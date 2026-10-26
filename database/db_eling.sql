-- ==========================================================
-- DOKUMEN BASIS DATA IMPAL: APLIKASI ELING
-- Nama Database: db_eling
-- ==========================================================

CREATE DATABASE IF NOT EXISTS `db_eling`;
USE `db_eling`;

-- ----------------------------------------------------------
-- 1.1 Tabel Pengguna
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `pengguna` (
  `KodePengguna` char(5) NOT NULL,
  `NamaPengguna` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  PRIMARY KEY (`KodePengguna`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------------------------------------
-- 1.2 Tabel Kategori
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `kategori` (
  `KodeKategori` char(5) NOT NULL,
  `NamaKategori` varchar(50) NOT NULL,
  `Deskripsi` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`KodeKategori`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------------------------------------
-- 1.3 Tabel Aktivitas
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `aktivitas` (
  `KodeAktivitas` char(5) NOT NULL,
  `KodePengguna` char(5) NOT NULL,
  `KodeKategori` char(5) NOT NULL,
  `NamaAktivitas` varchar(100) NOT NULL,
  `TanggalAktivitas` date NOT NULL,
  `StatusAktivitas` varchar(20) NOT NULL,
  PRIMARY KEY (`KodeAktivitas`),
  KEY `KodePengguna` (`KodePengguna`),
  KEY `KodeKategori` (`KodeKategori`),
  CONSTRAINT `aktivitas_ibfk_1` FOREIGN KEY (`KodePengguna`) REFERENCES `pengguna` (`KodePengguna`) ON DELETE CASCADE,
  CONSTRAINT `aktivitas_ibfk_2` FOREIGN KEY (`KodeKategori`) REFERENCES `kategori` (`KodeKategori`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------------------------------------
-- 1.4 Tabel Pengingat
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `pengingat` (
  `KodePengingat` char(5) NOT NULL,
  `KodeAktivitas` char(5) NOT NULL,
  `WaktuPengingat` datetime NOT NULL,
  `MetodePengingat` varchar(30) NOT NULL,
  `StatusPengingat` varchar(20) NOT NULL,
  PRIMARY KEY (`KodePengingat`),
  KEY `KodeAktivitas` (`KodeAktivitas`),
  CONSTRAINT `pengingat_ibfk_1` FOREIGN KEY (`KodeAktivitas`) REFERENCES `aktivitas` (`KodeAktivitas`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------------------------------------
-- 1.5 Tabel Riwayat Pengingat
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `riwayat_pengingat` (
  `KodeRiwayat` char(5) NOT NULL,
  `KodePengingat` char(5) NOT NULL,
  `WaktuProses` datetime NOT NULL,
  `StatusPengiriman` varchar(20) NOT NULL,
  `Keterangan` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`KodeRiwayat`),
  KEY `KodePengingat` (`KodePengingat`),
  CONSTRAINT `riwayat_pengingat_ibfk_1` FOREIGN KEY (`KodePengingat`) REFERENCES `pengingat` (`KodePengingat`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ==========================================================
-- 2. QUERY SEED DATA AWAL (ANGGOTA KELOMPOK & DUMMY DATA)
-- ==========================================================

-- 2.1 Insert Pengguna
INSERT INTO `pengguna` (`KodePengguna`, `NamaPengguna`, `Email`, `PasswordHash`) VALUES 
('U0001', 'Aziz Faadihilah', 'aziz@example.com', 'aziz123'),
('U0002', 'Gobes Jefri', 'gobes@example.com', 'jafri123'),
('U0003', 'Riandhika Bagug', 'bagug@example.com', 'bagus123'),
('U0004', 'Abied hyper', 'abied@example.com', 'abid123'),
('U0005', 'Sniper Atalah', 'sniper@example.com', 'sniper123')
ON DUPLICATE KEY UPDATE `NamaPengguna` = VALUES(`NamaPengguna`);

-- 2.2 Insert Kategori
INSERT INTO `kategori` (`KodeKategori`, `NamaKategori`, `Deskripsi`) VALUES 
('K0001', 'Pendidikan', 'Aktivitas belajar dan kuliah'),
('K0002', 'Pekerjaan', 'Aktivitas pekerjaan dan tugas'),
('K0003', 'Kesehatan', 'Aktivitas olahraga dan kesehatan'),
('K0004', 'Pribadi', 'Aktivitas dan kebutuhan pribadi'),
('K0005', 'Lainnya', 'Aktivitas lainnya')
ON DUPLICATE KEY UPDATE `NamaKategori` = VALUES(`NamaKategori`);

-- 2.3 Insert Aktivitas
INSERT INTO `aktivitas` (`KodeAktivitas`, `KodePengguna`, `KodeKategori`, `NamaAktivitas`, `TanggalAktivitas`, `StatusAktivitas`) VALUES 
('A0001', 'U0001', 'K0001', 'Mengerjakan tugas kuliah', '2026-10-20', 'Belum'),
('A0002', 'U0002', 'K0002', 'Menyelesaikan laporan', '2026-10-20', 'Belum'),
('A0003', 'U0003', 'K0003', 'Olahraga pagi', '2026-10-21', 'Belum'),
('A0004', 'U0004', 'K0004', 'Membayar tagihan', '2026-10-21', 'Belum'),
('A0005', 'U0005', 'K0001', 'Belajar untuk ujian', '2026-10-22', 'Belum')
ON DUPLICATE KEY UPDATE `NamaAktivitas` = VALUES(`NamaAktivitas`);

-- 2.4 Insert Pengingat
INSERT INTO `pengingat` (`KodePengingat`, `KodeAktivitas`, `WaktuPengingat`, `MetodePengingat`, `StatusPengingat`) VALUES 
('P0001', 'A0001', '2026-10-20 08:00:00', 'Notifikasi', 'Aktif'),
('P0002', 'A0002', '2026-10-20 10:00:00', 'Notifikasi', 'Aktif'),
('P0003', 'A0003', '2026-10-21 06:00:00', 'Alarm', 'Aktif'),
('P0004', 'A0004', '2026-10-21 12:00:00', 'Notifikasi', 'Aktif'),
('P0005', 'A0005', '2026-10-22 19:00:00', 'Alarm', 'Aktif')
ON DUPLICATE KEY UPDATE `StatusPengingat` = VALUES(`StatusPengingat`);

-- 2.5 Insert Riwayat Pengingat
INSERT INTO `riwayat_pengingat` (`KodeRiwayat`, `KodePengingat`, `WaktuProses`, `StatusPengiriman`, `Keterangan`) VALUES 
('R0001', 'P0001', '2026-10-20 08:00:00', 'Terkirim', 'Pengingat tugas kuliah'),
('R0002', 'P0002', '2026-10-20 10:00:00', 'Terkirim', 'Pengingat laporan'),
('R0003', 'P0003', '2026-10-21 06:00:00', 'Terkirim', 'Pengingat olahraga'),
('R0004', 'P0004', '2026-10-21 12:00:00', 'Terkirim', 'Pengingat pembayaran'),
('R0005', 'P0005', '2026-10-22 19:00:00', 'Terkirim', 'Pengingat belajar')
ON DUPLICATE KEY UPDATE `StatusPengiriman` = VALUES(`StatusPengiriman`);
