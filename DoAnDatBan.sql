/* =========================================================
   DATABASE: DoAnDatBan
   PURPOSE : Website đặt bàn (ASP Classic + SQL Server)
   NOTE    : Run as a single script in SSMS
========================================================= */

-- 0) Create DB
IF DB_ID(N'DoAnDatBan') IS NULL
BEGIN
    CREATE DATABASE DoAnDatBan;
END
GO

USE DoAnDatBan;
GO

/* 1) Clean up (optional rerun safety)
   Comment this block out if you already have data you want to keep.
*/
IF OBJECT_ID('dbo.ReservationStatusHistory','U') IS NOT NULL DROP TABLE dbo.ReservationStatusHistory;
IF OBJECT_ID('dbo.ReservationTables','U') IS NOT NULL DROP TABLE dbo.ReservationTables;
IF OBJECT_ID('dbo.Reservations','U') IS NOT NULL DROP TABLE dbo.Reservations;
IF OBJECT_ID('dbo.DiningTables','U') IS NOT NULL DROP TABLE dbo.DiningTables;
IF OBJECT_ID('dbo.TimeSlots','U') IS NOT NULL DROP TABLE dbo.TimeSlots;
IF OBJECT_ID('dbo.AdminUsers','U') IS NOT NULL DROP TABLE dbo.AdminUsers;
IF OBJECT_ID('dbo.SystemSettings','U') IS NOT NULL DROP TABLE dbo.SystemSettings;
IF OBJECT_ID('dbo.AppLogs','U') IS NOT NULL DROP TABLE dbo.AppLogs;
GO

/* 2) Settings (1 row per key)
   Useful for: restaurant name, phone, opening hours text, etc.
*/
CREATE TABLE dbo.SystemSettings (
    [Key]           NVARCHAR(100) NOT NULL PRIMARY KEY,
    [Value]         NVARCHAR(4000) NULL,
    UpdatedAt       DATETIME2(0) NOT NULL CONSTRAINT DF_SystemSettings_UpdatedAt DEFAULT SYSDATETIME()
);
GO

/* 3) Admin users (for admin login)
   - PasswordHash: store a hash you compute in ASP (recommended: SHA-256 + salt at minimum).
*/
CREATE TABLE dbo.AdminUsers (
    AdminId         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Username        NVARCHAR(50) NOT NULL,
    PasswordHash    NVARCHAR(200) NOT NULL,
    PasswordSalt    NVARCHAR(100) NULL,
    DisplayName     NVARCHAR(100) NULL,
    Role            NVARCHAR(20) NOT NULL CONSTRAINT DF_AdminUsers_Role DEFAULT N'Admin', -- Admin/Staff
    IsActive        BIT NOT NULL CONSTRAINT DF_AdminUsers_IsActive DEFAULT (1),
    LastLoginAt     DATETIME2(0) NULL,
    CreatedAt       DATETIME2(0) NOT NULL CONSTRAINT DF_AdminUsers_CreatedAt DEFAULT SYSDATETIME(),
    UpdatedAt       DATETIME2(0) NOT NULL CONSTRAINT DF_AdminUsers_UpdatedAt DEFAULT SYSDATETIME()
);
GO

CREATE UNIQUE INDEX UX_AdminUsers_Username ON dbo.AdminUsers(Username);
GO

/* 4) Time slots (reservation time blocks)
   Example: 18:00-19:30, 19:30-21:00
*/
CREATE TABLE dbo.TimeSlots (
    SlotId          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SlotName        NVARCHAR(50) NOT NULL,            -- e.g. "18:00 - 19:30"
    StartTime       TIME(0) NOT NULL,
    EndTime         TIME(0) NOT NULL,
    IsActive        BIT NOT NULL CONSTRAINT DF_TimeSlots_IsActive DEFAULT (1),
    SortOrder       INT NOT NULL CONSTRAINT DF_TimeSlots_SortOrder DEFAULT (0),
    CreatedAt       DATETIME2(0) NOT NULL CONSTRAINT DF_TimeSlots_CreatedAt DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_TimeSlots_IsActive_SortOrder ON dbo.TimeSlots(IsActive, SortOrder);
GO

/* 5) Dining tables (optional but recommended)
   If you don’t want to assign a physical table, you can still keep this table for future use.
*/
CREATE TABLE dbo.DiningTables (
    TableId         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TableCode       NVARCHAR(20) NOT NULL,            -- e.g. T01, A1, VIP2
    TableName       NVARCHAR(50) NULL,                -- e.g. "Bàn cửa sổ"
    Capacity        INT NOT NULL,
    IsActive        BIT NOT NULL CONSTRAINT DF_DiningTables_IsActive DEFAULT (1),
    Notes           NVARCHAR(200) NULL,
    CreatedAt       DATETIME2(0) NOT NULL CONSTRAINT DF_DiningTables_CreatedAt DEFAULT SYSDATETIME()
);
GO

CREATE UNIQUE INDEX UX_DiningTables_TableCode ON dbo.DiningTables(TableCode);
CREATE INDEX IX_DiningTables_IsActive_Capacity ON dbo.DiningTables(IsActive, Capacity);
GO

/* 6) Reservations (core)
   Status workflow:
   - Pending: khách đặt xong, chờ xác nhận
   - Confirmed: admin xác nhận
   - Cancelled: hủy
   - Completed: đã phục vụ xong (optional)
*/
CREATE TABLE dbo.Reservations (
    ReservationId       BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    FullName            NVARCHAR(100) NOT NULL,
    Email               NVARCHAR(254) NULL,
    Phone               NVARCHAR(20) NOT NULL,

    Guests              INT NOT NULL,
    ReservationDate     DATE NOT NULL,
    SlotId              INT NOT NULL,

    Note                NVARCHAR(500) NULL,

    Status              NVARCHAR(20) NOT NULL CONSTRAINT DF_Reservations_Status DEFAULT N'Pending',
    CancelReason        NVARCHAR(300) NULL,

    CreatedAt           DATETIME2(0) NOT NULL CONSTRAINT DF_Reservations_CreatedAt DEFAULT SYSDATETIME(),
    UpdatedAt           DATETIME2(0) NOT NULL CONSTRAINT DF_Reservations_UpdatedAt DEFAULT SYSDATETIME(),
    ConfirmedAt         DATETIME2(0) NULL,
    CancelledAt         DATETIME2(0) NULL,
    CompletedAt         DATETIME2(0) NULL,

    -- meta for ops / anti-spam (optional)
    SourceIP            NVARCHAR(45) NULL,
    UserAgent           NVARCHAR(300) NULL
);
GO

ALTER TABLE dbo.Reservations
ADD CONSTRAINT FK_Reservations_TimeSlots
FOREIGN KEY (SlotId) REFERENCES dbo.TimeSlots(SlotId);
GO

-- Basic data rules
ALTER TABLE dbo.Reservations
ADD CONSTRAINT CK_Reservations_Guests CHECK (Guests >= 1 AND Guests <= 50);
GO

ALTER TABLE dbo.Reservations
ADD CONSTRAINT CK_Reservations_Status CHECK (Status IN (N'Pending', N'Confirmed', N'Cancelled', N'Completed'));
GO

-- Useful indexes for admin filtering
CREATE INDEX IX_Reservations_Date_Status ON dbo.Reservations(ReservationDate, Status);
CREATE INDEX IX_Reservations_Slot_Date ON dbo.Reservations(SlotId, ReservationDate);
CREATE INDEX IX_Reservations_Phone ON dbo.Reservations(Phone);
GO

/* 6.1) Prevent duplicate active reservations by phone+date+slot
   This allows:
   - multiple rows if older ones are Cancelled/Completed
   This prevents:
   - a phone booking same date+slot twice when status is Pending/Confirmed
*/
CREATE UNIQUE INDEX UX_Reservations_NoDuplicateActive
ON dbo.Reservations(Phone, ReservationDate, SlotId)
WHERE Status IN (N'Pending', N'Confirmed');
GO

/* 7) ReservationTables (optional assignment of physical tables)
   - Admin can assign 1 or multiple tables for large groups.
*/
CREATE TABLE dbo.ReservationTables (
    ReservationId   BIGINT NOT NULL,
    TableId         INT NOT NULL,
    AssignedAt      DATETIME2(0) NOT NULL CONSTRAINT DF_ReservationTables_AssignedAt DEFAULT SYSDATETIME(),
    AssignedByAdminId INT NULL,
    PRIMARY KEY (ReservationId, TableId)
);
GO

ALTER TABLE dbo.ReservationTables
ADD CONSTRAINT FK_ReservationTables_Reservations
FOREIGN KEY (ReservationId) REFERENCES dbo.Reservations(ReservationId) ON DELETE CASCADE;
GO

ALTER TABLE dbo.ReservationTables
ADD CONSTRAINT FK_ReservationTables_DiningTables
FOREIGN KEY (TableId) REFERENCES dbo.DiningTables(TableId);
GO

ALTER TABLE dbo.ReservationTables
ADD CONSTRAINT FK_ReservationTables_AdminUsers
FOREIGN KEY (AssignedByAdminId) REFERENCES dbo.AdminUsers(AdminId);
GO

/* 8) Status history (audit trail)
   Helps you track who changed what and when.
*/
CREATE TABLE dbo.ReservationStatusHistory (
    HistoryId           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ReservationId       BIGINT NOT NULL,
    OldStatus           NVARCHAR(20) NOT NULL,
    NewStatus           NVARCHAR(20) NOT NULL,
    Note                NVARCHAR(300) NULL,
    ChangedByAdminId    INT NULL,
    ChangedAt           DATETIME2(0) NOT NULL CONSTRAINT DF_ReservationStatusHistory_ChangedAt DEFAULT SYSDATETIME()
);
GO

ALTER TABLE dbo.ReservationStatusHistory
ADD CONSTRAINT FK_ReservationStatusHistory_Reservations
FOREIGN KEY (ReservationId) REFERENCES dbo.Reservations(ReservationId) ON DELETE CASCADE;
GO

ALTER TABLE dbo.ReservationStatusHistory
ADD CONSTRAINT FK_ReservationStatusHistory_AdminUsers
FOREIGN KEY (ChangedByAdminId) REFERENCES dbo.AdminUsers(AdminId);
GO

CREATE INDEX IX_ReservationStatusHistory_ReservationId ON dbo.ReservationStatusHistory(ReservationId, ChangedAt DESC);
GO

/* 9) App logs (optional but helpful)
   You can write logs from ASP when email fails, DB errors, etc.
*/
CREATE TABLE dbo.AppLogs (
    LogId           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    LogLevel        NVARCHAR(10) NOT NULL,        -- INFO/WARN/ERROR
    Message         NVARCHAR(1000) NOT NULL,
    Detail          NVARCHAR(4000) NULL,
    CreatedAt       DATETIME2(0) NOT NULL CONSTRAINT DF_AppLogs_CreatedAt DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_AppLogs_Level_CreatedAt ON dbo.AppLogs(LogLevel, CreatedAt DESC);
GO

/* 10) Seed data (time slots + tables + settings + admin placeholder)
   - You can change these anytime.
*/

-- Settings
INSERT INTO dbo.SystemSettings([Key],[Value]) VALUES
(N'RestaurantName', N'Nhà hàng của tôi'),
(N'Hotline', N'0123 456 789'),
(N'Address', N''),
(N'EmailFrom', N'noreply@yourdomain.com');
GO

-- Default time slots (edit to your needs)
INSERT INTO dbo.TimeSlots(SlotName, StartTime, EndTime, IsActive, SortOrder) VALUES
(N'11:00 - 12:30', '11:00', '12:30', 1, 10),
(N'12:30 - 14:00', '12:30', '14:00', 1, 20),
(N'18:00 - 19:30', '18:00', '19:30', 1, 30),
(N'19:30 - 21:00', '19:30', '21:00', 1, 40);
GO

-- Example tables (optional)
INSERT INTO dbo.DiningTables(TableCode, TableName, Capacity, IsActive, Notes) VALUES
(N'T01', N'Bàn 2 người', 2, 1, NULL),
(N'T02', N'Bàn 4 người', 4, 1, NULL),
(N'T03', N'Bàn 4 người', 4, 1, NULL),
(N'VIP1', N'Phòng VIP', 10, 1, NULL);
GO

-- Admin placeholder (CHANGE THIS in your app)
-- PasswordHash should NOT be plain text. Replace it with a real hash later.
INSERT INTO dbo.AdminUsers(Username, PasswordHash, PasswordSalt, DisplayName, Role, IsActive)
VALUES (N'admin', N'CHANGE_ME_HASH', NULL, N'Administrator', N'Admin', 1);
GO

PRINT 'DB DoAnDatBan created and initialized successfully.';
GO
