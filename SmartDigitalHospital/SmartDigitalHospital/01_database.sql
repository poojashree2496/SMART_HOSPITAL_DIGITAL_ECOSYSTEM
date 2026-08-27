-- ============================================================
-- SMART DIGITAL HOSPITAL ECOSYSTEM
-- DATABASE STRUCTURE
-- MySQL 5.7 Compatible
-- ============================================================

DROP DATABASE IF EXISTS SmartDigitalHospital;

CREATE DATABASE SmartDigitalHospital;

USE SmartDigitalHospital;


-- ============================================================
-- 1. DEPARTMENT
-- ============================================================

CREATE TABLE Department (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    DepartmentTiming VARCHAR(100),
    Location VARCHAR(100)
);


-- ============================================================
-- 2. DOCTOR
-- ============================================================

CREATE TABLE Doctor (
    DoctorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50),
    Gender VARCHAR(10),
    Phone VARCHAR(15),
    Email VARCHAR(100),
    Specialization VARCHAR(100),
    Schedule VARCHAR(500),
    Availability ENUM('Available','On Leave','Not Available')
        DEFAULT 'Available',
    DepartmentID INT,
    Experience INT,

    CONSTRAINT FK_Doctor_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES Department(DepartmentID)
);


-- ============================================================
-- 3. PATIENT
-- ============================================================

CREATE TABLE Patient (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50),
    Gender VARCHAR(10),
    DOB DATE,
    BloodGroup VARCHAR(5),
    Phone VARCHAR(15),
    Email VARCHAR(100),
    Address VARCHAR(255),
    Emergency_Contact VARCHAR(15),
    Medical_History VARCHAR(500)
);


-- ============================================================
-- 4. AMBULANCE
-- ============================================================

CREATE TABLE Ambulance (
    AmbulanceID INT AUTO_INCREMENT PRIMARY KEY,
    VehicleNumber VARCHAR(20) UNIQUE NOT NULL,
    DriverName VARCHAR(100),
    DriverPhone VARCHAR(15),
    Availability ENUM('Available','On Duty','Maintenance')
        DEFAULT 'Available',
    Status VARCHAR(50),
    CurrentLocation VARCHAR(100),
    PatientID INT NULL,

    CONSTRAINT FK_Ambulance_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID)
);


-- ============================================================
-- 5. APPOINTMENT
-- ============================================================

CREATE TABLE Appointment (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AmbulanceID INT NULL,
    AppointmentDate DATE,
    AppointmentTime TIME,
    Status ENUM('Scheduled','Completed','Cancelled','No Show')
        DEFAULT 'Scheduled',
    Reason VARCHAR(255),

    CONSTRAINT FK_Appointment_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID),

    CONSTRAINT FK_Appointment_Doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor(DoctorID),

    CONSTRAINT FK_Appointment_Ambulance
        FOREIGN KEY (AmbulanceID)
        REFERENCES Ambulance(AmbulanceID)
);


-- ============================================================
-- 6. ROOM
-- ============================================================

CREATE TABLE Room (
    RoomID INT AUTO_INCREMENT PRIMARY KEY,
    RoomNumber VARCHAR(10) UNIQUE NOT NULL,
    RoomType VARCHAR(50),
    ChargesPerDay DECIMAL(10,2),
    Availability ENUM('Available','Occupied','Maintenance')
        DEFAULT 'Available'
);


-- ============================================================
-- 7. ADMISSION
-- ============================================================

CREATE TABLE Admission (
    AdmissionID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    RoomID INT NOT NULL,
    AdmissionDate DATETIME,
    DischargeDate DATETIME,

    CONSTRAINT FK_Admission_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID),

    CONSTRAINT FK_Admission_Room
        FOREIGN KEY (RoomID)
        REFERENCES Room(RoomID)
);


-- ============================================================
-- 8. LABORATORY
-- ============================================================

CREATE TABLE Laboratory (
    LabID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentID INT NULL,
    TestName VARCHAR(100),
    TestDate DATE,
    Result VARCHAR(255),
    LabTechnician VARCHAR(100),
    Status ENUM('Pending','Completed','Cancelled')
        DEFAULT 'Pending',

    CONSTRAINT FK_Lab_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID),

    CONSTRAINT FK_Lab_Doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor(DoctorID),

    CONSTRAINT FK_Lab_Appointment
        FOREIGN KEY (AppointmentID)
        REFERENCES Appointment(AppointmentID)
);


-- ============================================================
-- 9. PHARMACY
-- ============================================================

CREATE TABLE Pharmacy (
    MedicineID INT AUTO_INCREMENT PRIMARY KEY,
    MedicineName VARCHAR(100) NOT NULL,
    Manufacturer VARCHAR(100),
    Stock INT NOT NULL DEFAULT 0,
    ExpiryDate DATE,
    Price DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT chk_pharmacy_stock
        CHECK (Stock >= 0)
);


-- ============================================================
-- 10. PRESCRIPTION
-- ============================================================

CREATE TABLE Prescription (
    PrescriptionID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentID INT NULL,
    MedicineID INT NOT NULL,
    Dosage VARCHAR(50),
    Duration VARCHAR(50),
    Instructions VARCHAR(255),

    CONSTRAINT FK_Prescription_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID),

    CONSTRAINT FK_Prescription_Doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor(DoctorID),

    CONSTRAINT FK_Prescription_Appointment
        FOREIGN KEY (AppointmentID)
        REFERENCES Appointment(AppointmentID),

    CONSTRAINT FK_Prescription_Medicine
        FOREIGN KEY (MedicineID)
        REFERENCES Pharmacy(MedicineID)
);


-- ============================================================
-- 11. INSURANCE
-- ============================================================

CREATE TABLE Insurance (
    InsuranceID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    InsuranceProvider VARCHAR(100),
    PolicyNumber VARCHAR(50) UNIQUE,
    CoverageAmount DECIMAL(10,2),
    ExpiryDate DATE,
    ClaimStatus ENUM('Pending','Approved','Rejected')
        DEFAULT 'Pending',

    CONSTRAINT FK_Insurance_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID)
);


-- ============================================================
-- 12. BILLING
-- ============================================================

CREATE TABLE Billing (
    BillID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    AppointmentID INT NULL,
    ConsultationFee DECIMAL(10,2) DEFAULT 0.00,
    LabCharge DECIMAL(10,2) DEFAULT 0.00,
    MedicineCharge DECIMAL(10,2) DEFAULT 0.00,
    RoomCharge DECIMAL(10,2) DEFAULT 0.00,
    InsuranceID INT NULL,
    TotalAmount DECIMAL(10,2) DEFAULT 0.00,
    InsuranceCovered DECIMAL(10,2) DEFAULT 0.00,
    AmountToPay DECIMAL(10,2) DEFAULT 0.00,
    PaymentStatus ENUM('Paid','Unpaid','Partial')
        DEFAULT 'Unpaid',
    BillDate DATE,

    CONSTRAINT FK_Billing_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID),

    CONSTRAINT FK_Billing_Appointment
        FOREIGN KEY (AppointmentID)
        REFERENCES Appointment(AppointmentID),

    CONSTRAINT FK_Billing_Insurance
        FOREIGN KEY (InsuranceID)
        REFERENCES Insurance(InsuranceID)
);


-- ============================================================
-- 13. STAFF
-- ============================================================

CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Role VARCHAR(50),
    Phone VARCHAR(15),
    Salary DECIMAL(10,2),
    DepartmentID INT,

    CONSTRAINT FK_Staff_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES Department(DepartmentID)
);


-- ============================================================
-- 14. MEDICAL RECORD
-- ============================================================

CREATE TABLE MedicalRecord (
    RecordID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    Diagnosis VARCHAR(255),
    Treatment VARCHAR(255),
    RecordDate DATE,

    CONSTRAINT FK_Record_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID),

    CONSTRAINT FK_Record_Doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor(DoctorID)
);


-- ============================================================
-- 15. AI PREDICTION
-- ============================================================

CREATE TABLE AI_Prediction (
    PredictionID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    Symptoms VARCHAR(500),
    PredictedDisease VARCHAR(150),
    Confidence DECIMAL(5,2),
    PredictionDate DATETIME,

    CONSTRAINT FK_AI_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient(PatientID)
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_doctor_department
    ON Doctor(DepartmentID);

CREATE INDEX idx_appointment_patient
    ON Appointment(PatientID);

CREATE INDEX idx_appointment_doctor
    ON Appointment(DoctorID);

CREATE INDEX idx_admission_patient
    ON Admission(PatientID);

CREATE INDEX idx_admission_room
    ON Admission(RoomID);

CREATE INDEX idx_lab_patient
    ON Laboratory(PatientID);

CREATE INDEX idx_lab_doctor
    ON Laboratory(DoctorID);

CREATE INDEX idx_prescription_patient
    ON Prescription(PatientID);

CREATE INDEX idx_prescription_medicine
    ON Prescription(MedicineID);

CREATE INDEX idx_billing_patient
    ON Billing(PatientID);

CREATE INDEX idx_insurance_patient
    ON Insurance(PatientID);

CREATE INDEX idx_ambulance_patient
    ON Ambulance(PatientID);

CREATE INDEX idx_prediction_patient
    ON AI_Prediction(PatientID);


-- ============================================================
-- VERIFY TABLES
-- ============================================================

SHOW TABLES;