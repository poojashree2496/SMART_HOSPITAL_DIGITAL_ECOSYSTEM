-- ============================================
-- SECTION 1: HOSPITAL MANAGEMENT SYSTEM DATABASE
-- ============================================

-- Create Database
CREATE DATABASE HospitalManagementSystem;

-- Use Database
USE HospitalManagementSystem;

-- ============================================
-- 1.1. Department
-- ============================================
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(100) NOT NULL,
    DepartmentTiming VARCHAR(),
    Location VARCHAR(100)
);

-- ============================================
-- 1.2. Doctor
-- ============================================
CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50),
    Gender VARCHAR(10),
    Phone VARCHAR(15),
    Email VARCHAR(100),
    Specialization VARCHAR(100),
    Schedule VARCHAR(500),
    Availability ENUM('Available','On Leave','Not Available') DEFAULT 'Available',

    DepartmentID INT,
    Experience INT,

    CONSTRAINT FK_Doctor_Department
    FOREIGN KEY (DepartmentID)
    REFERENCES Department(DepartmentID)
);

-- ============================================
-- 1.3. Patient
-- ============================================
CREATE TABLE Patient (
    PatientID INT PRIMARY KEY IDENTITY(1,1),
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

-- ============================================
-- 1.4. Ambulance
-- ============================================
CREATE TABLE Ambulance (
    AmbulanceID INT PRIMARY KEY IDENTITY(1,1),
    VehicleNumber VARCHAR(20) UNIQUE NOT NULL,
    DriverName VARCHAR(100),
    DriverPhone VARCHAR(15),
    Availability ENUM('Available','On Duty','Maintainence')DEFAULT'Available',
    Status VARCHAR(20),
    CurrentLocation VARCHAR(100)
);

-- ============================================
-- 1.5. Appointment
-- ============================================
CREATE TABLE Appointment (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AmbulanceID INT NULL,
    AppointmentDate DATE,
    AppointmentTime TIME,
    Status VARCHAR(30),

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

-- ============================================
-- 1.6. Room
-- ============================================
CREATE TABLE Room (
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    PatientID VARCHAR ();
    RoomNumber VARCHAR(10) UNIQUE,
    RoomType VARCHAR(50),
    ChargesPerDay DECIMAL(10,2),
    Availability VARCHAR(20)
);

-- ============================================
-- 1.7. Admission
-- ============================================
CREATE TABLE Admission (
    AdmissionID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT,
    RoomID INT,
    AdmissionDate DATE,
    DischargeDate DATE,

    CONSTRAINT FK_Admission_Patient
    FOREIGN KEY (PatientID)
    REFERENCES Patient(PatientID),

    CONSTRAINT FK_Admission_Room
    FOREIGN KEY (RoomID)
    REFERENCES Room(RoomID)
);

-- ============================================
-- 1.8. Laboratory
-- ============================================
CREATE TABLE Laboratory (
    LabID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentID INT,
    TestName VARCHAR(100),
    TestDate DATE,
    Result VARCHAR(255),
    LabTechnician VARCHAR(100),
    Status ENUM('Pending','Completed','Cancelled')DEFAULT'Pending'

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

-- ============================================
-- 1.9. Prescription
-- ============================================
CREATE TABLE Prescription (
    PrescriptionID INT PRIMARY KEY IDENTITY(1,1),
    Patient_ID INT NOT NULL,
    Doctor_ID INT NOT NULL,
    Appointment_ID INT,
    MedicineName VARCHAR(100),
    Medicine_ID INT NOT NULL,
    Dosage VARCHAR(50),
    Duration VARCHAR(50),
    Instructions VARCHAR(255),

    CONSTRAINT FK_Prescription_Appointment
        FOREIGN KEY (AppointmentID)
        REFERENCES Appointment(AppointmentID)
    CONSTRAINT fk_prescription_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_prescription_doctor
        FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_prescription_medicine
        FOREIGN KEY (Medicine_ID) REFERENCES Pharmacy(Medicine_ID)
        ON DELETE CASCADE ON UPDATE CASCADE

);

-- ============================================
-- 1.10. Insurance
-- ============================================
CREATE TABLE Insurance (
    InsuranceID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT NOT NULL,
    InsuranceProvider VARCHAR(100),
    PolicyNumber VARCHAR(50) UNIQUE,
    CoverageAmount DECIMAL(10,2),
    ExpiryDate DATE,
    ClaimStatus ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',

    CONSTRAINT FK_Insurance_Patient
    FOREIGN KEY (PatientID)
    REFERENCES Patient(PatientID)
);

-- ============================================
-- 1.11. Billing
-- ============================================
CREATE TABLE Billing (
    BillID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT,
    AppointmentID INT,
    Consultation_Fee  DECIMAL(10,2) DEFAULT 0.00,
    Lab_Charge DECIMAL(10,2) DEFAULT 0.00,
    Medicine_Charge DECIMAL(10,2) DEFAULT 0.00,
    Room_Charge DECIMAL(10,2) DEFAULT 0.00,
    InsuranceID INT NULL,
    TotalAmount DECIMAL(10,2),
    InsuranceCovered DECIMAL(10,2),
    AmountToPay DECIMAL(10,2),
    PaymentStatus ENUM('Paid','Unpaid','Partial')DEFAULT 'Unpaid',
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

-- ============================================
-- 1.12. Staff
-- ============================================
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
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

-- ============================================
-- 1.13. Medical Record
-- ============================================
CREATE TABLE MedicalRecord (
    RecordID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT,
    DoctorID INT,
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
-- ============================================
-- 1.14. Pharmacy
-- ============================================
CREATE TABLE Pharmacy (
    Medicine_ID    INT AUTO_INCREMENT PRIMARY KEY,
    Medicine_Name  VARCHAR(100) NOT NULL,
    Manufacturer   VARCHAR(100),
    Stock          INT NOT NULL DEFAULT 0,
    Expiry_Date    DATE,
    Price          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT chk_pharmacy_stock CHECK (Stock >= 0)
);
-- ------------------------------------------------------------
-- 1.15 INDEXES (speed up common lookups / joins)
-- ------------------------------------------------------------
CREATE INDEX idx_doctor_department      ON Doctor(Department_ID);
CREATE INDEX idx_appointment_patient    ON Appointment(Patient_ID);
CREATE INDEX idx_appointment_doctor     ON Appointment(Doctor_ID);
CREATE INDEX idx_admission_patient      ON Admission(Patient_ID);
CREATE INDEX idx_lab_patient            ON Laboratory(Patient_ID);
CREATE INDEX idx_lab_doctor             ON Laboratory(Doctor_ID);
CREATE INDEX idx_prescription_patient   ON Prescription(Patient_ID);
CREATE INDEX idx_prescription_medicine  ON Prescription(Medicine_ID);
CREATE INDEX idx_billing_patient        ON Billing(Patient_ID);
CREATE INDEX idx_insurance_patient      ON Insurance(Patient_ID);
CREATE INDEX idx_ambulance_patient      ON Ambulance(Patient_ID);
CREATE INDEX idx_prediction_patient     ON AI_Prediction(Patient_ID);

-- ============================================================
-- SECTION 2: SEED DATA (expanded)
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Departments (8 total; Neurology & Oncology are new)
-- ------------------------------------------------------------
INSERT INTO Department (Department_Name, Floor) VALUES
('Cardiology', '2'),          -- 1
('Orthopedics', '3'),         -- 2
('General Medicine', '1'),    -- 3
('Radiology', '1'),           -- 4
('Pediatrics', '2'),          -- 5
('Emergency', 'Ground'),      -- 6
('Neurology', '4'),           -- 7  (new)
('Oncology', '4');            -- 8  (new)

-- ------------------------------------------------------------
-- 2.2 Doctors (10 total; Endocrinologist, Pulmonologist,
--     Neurologist and Oncologist are new)
-- ------------------------------------------------------------
INSERT INTO Doctor (Doctor_Name, Specialization, Phone, Email, Department_ID, Availability) VALUES
('Dr. Arjun Mehta', 'Cardiologist', '9000000001', 'arjun.mehta@hospital.com', 1, 'Available'),        -- 1
('Dr. Priya Nair', 'Orthopedic Surgeon', '9000000002', 'priya.nair@hospital.com', 2, 'Available'),     -- 2
('Dr. Ramesh Iyer', 'General Physician', '9000000003', 'ramesh.iyer@hospital.com', 3, 'Available'),    -- 3
('Dr. Lakshmi Menon', 'Pediatrician', '9000000004', 'lakshmi.menon@hospital.com', 5, 'Available'),     -- 4
('Dr. Vikram Rao', 'Emergency Medicine', '9000000005', 'vikram.rao@hospital.com', 6, 'On Leave'),      -- 5
('Dr. Anitha Kumar', 'Radiologist', '9000000006', 'anitha.kumar@hospital.com', 4, 'Available'),        -- 6
('Dr. Meera Pillai', 'Endocrinologist', '9000000007', 'meera.pillai@hospital.com', 3, 'Available'),    -- 7  (new)
('Dr. Sanjay Gupta', 'Pulmonologist', '9000000008', 'sanjay.gupta@hospital.com', 3, 'Available'),      -- 8  (new)
('Dr. Karthik Subramaniam', 'Neurologist', '9000000009', 'karthik.subramaniam@hospital.com', 7, 'Available'), -- 9  (new)
('Dr. Divya Chandran', 'Oncologist', '9000000010', 'divya.chandran@hospital.com', 8, 'On Leave');      -- 10 (new)

UPDATE Department SET Head_Doctor = 1  WHERE Department_ID = 1;
UPDATE Department SET Head_Doctor = 2  WHERE Department_ID = 2;
UPDATE Department SET Head_Doctor = 3  WHERE Department_ID = 3;
UPDATE Department SET Head_Doctor = 6  WHERE Department_ID = 4;
UPDATE Department SET Head_Doctor = 4  WHERE Department_ID = 5;
UPDATE Department SET Head_Doctor = 5  WHERE Department_ID = 6;
UPDATE Department SET Head_Doctor = 9  WHERE Department_ID = 7;
UPDATE Department SET Head_Doctor = 10 WHERE Department_ID = 8;

-- ------------------------------------------------------------
-- 2.3 Patients (8 total)
-- ------------------------------------------------------------
INSERT INTO Patient (First_Name, Last_Name, Gender, DOB, Phone, Email, Address, Blood_Group, Emergency_Contact, Medical_History) VALUES
('Karthik', 'Raja', 'Male', '1990-05-14', '9111111111', 'karthik.raja@mail.com', 'Avadi, Chennai', 'O+', '9222222222', 'Hypertension'),                          -- 1
('Divya', 'Suresh', 'Female', '1995-11-02', '9333333333', 'divya.suresh@mail.com', 'Ambattur, Chennai', 'B+', '9444444444', 'None'),                            -- 2
('Mohammed', 'Farooq', 'Male', '1982-03-21', '9555555555', 'mohammed.farooq@mail.com', 'Poonamallee, Chennai', 'A+', '9666666666', 'Type 2 Diabetes'),          -- 3
('Anjali', 'Krishnan', 'Female', '2001-07-09', '9777777777', 'anjali.krishnan@mail.com', 'Thiruvallur', 'AB+', '9888888888', 'Asthma'),                          -- 4
('Baby', 'Farooq', 'Female', '2023-01-15', NULL, NULL, 'Poonamallee, Chennai', 'A+', '9666666666', 'None'),                                                     -- 5
('Suresh', 'Babu', 'Male', '1975-09-10', '9111222233', 'suresh.babu@mail.com', 'Red Hills, Chennai', 'O-', '9111222234', 'Coronary Artery Disease'),            -- 6  (new)
('Kavya', 'Ramesh', 'Female', '1998-04-18', '9111222244', 'kavya.ramesh@mail.com', 'Villivakkam, Chennai', 'B-', '9111222245', 'Chronic Migraine'),             -- 7  (new)
('Ganesan', 'Pillai', 'Male', '1960-12-05', '9111222255', 'ganesan.pillai@mail.com', 'Tiruvottiyur, Chennai', 'AB-', '9111222256', 'Chronic Kidney Disease, Type 2 Diabetes'); -- 8  (new)

-- ------------------------------------------------------------
-- 2.4 Pharmacy (8 medicines total)
-- ------------------------------------------------------------
INSERT INTO Pharmacy (Medicine_Name, Manufacturer, Stock, Expiry_Date, Price) VALUES
('Paracetamol 500mg', 'Cipla', 500, '2027-06-30', 2.50),        -- 1
('Amoxicillin 250mg', 'Sun Pharma', 300, '2026-12-31', 5.00),   -- 2
('Metformin 500mg', 'Sun Pharma', 40, '2027-01-31', 3.20),      -- 3
('Salbutamol Inhaler', 'Cipla', 15, '2026-09-30', 180.00),      -- 4
('Insulin Glargine', 'Novo Nordisk', 25, '2026-11-30', 650.00), -- 5
('Ibuprofen 400mg', 'Cipla', 200, '2027-03-31', 3.00),          -- 6  (new)
('Amlodipine 5mg', 'Sun Pharma', 150, '2027-05-31', 4.50),      -- 7  (new)
('Atorvastatin 20mg', 'Dr. Reddy''s', 100, '2027-08-31', 6.75); -- 8  (new)

-- ------------------------------------------------------------
-- 2.5 Appointments (10 total)
-- ------------------------------------------------------------
INSERT INTO Appointment (Patient_ID, Doctor_ID, Appointment_Date, Appointment_Time, Status, Reason) VALUES
(1, 1, '2026-08-02', '10:30:00', 'Scheduled', 'Chest pain follow-up'),                     -- 1
(2, 3, '2026-08-03', '11:00:00', 'Scheduled', 'General checkup'),                          -- 2
(3, 7, '2026-08-01', '09:00:00', 'Completed', 'Diabetes review'),                          -- 3  (doctor fixed: Endocrinologist)
(4, 8, '2026-08-04', '15:00:00', 'Scheduled', 'Asthma follow-up'),                         -- 4  (doctor fixed: Pulmonologist)
(5, 4, '2026-08-04', '15:30:00', 'Scheduled', 'Newborn checkup'),                          -- 5
(2, 3, '2026-07-20', '10:00:00', 'Completed', 'Annual physical'),                          -- 6
(6, 1, '2026-08-05', '09:30:00', 'Scheduled', 'Cardiac evaluation'),                       -- 7  (new)
(7, 9, '2026-08-05', '13:00:00', 'Scheduled', 'Migraine consultation'),                    -- 8  (new)
(8, 7, '2026-08-06', '10:00:00', 'Scheduled', 'Diabetes & kidney follow-up'),              -- 9  (new)
(8, 10, '2026-08-07', '11:30:00', 'Scheduled', 'Oncology screening');                      -- 10 (new)

-- ------------------------------------------------------------
-- 2.6 Admissions (4 total)
-- ------------------------------------------------------------
INSERT INTO Admission (Patient_ID, Ward, Room_No, Bed_No, Admission_Date, Discharge_Date) VALUES
(3, 'General Ward', 'G-12', 'B1', '2026-07-25 08:00:00', NULL),                 -- 1
(2, 'Maternity Ward', 'M-04', 'B2', '2026-06-10 14:00:00', '2026-06-13 10:00:00'), -- 2
(6, 'Cardiac ICU', 'C-02', 'B1', '2026-08-05 09:00:00', NULL),                  -- 3  (new)
(8, 'General Ward', 'G-15', 'B2', '2026-07-28 07:00:00', '2026-08-02 12:00:00'); -- 4  (new)

-- ------------------------------------------------------------
-- 2.7 Laboratory tests (7 total)
-- ------------------------------------------------------------
INSERT INTO Laboratory (Patient_ID, Doctor_ID, Test_Name, Test_Date, Result, Status) VALUES
(1, 1, 'ECG', '2026-08-02', 'Normal sinus rhythm', 'Completed'),                    -- 1
(3, 7, 'HbA1c', '2026-07-26', '7.8%', 'Completed'),                                 -- 2  (doctor fixed)
(4, 8, 'Spirometry', '2026-08-04', NULL, 'Pending'),                                -- 3  (doctor fixed)
(1, 1, 'Lipid Profile', '2026-08-02', NULL, 'Pending'),                             -- 4
(6, 1, 'Troponin Test', '2026-08-05', 'Elevated', 'Completed'),                     -- 5  (new)
(7, 9, 'MRI Brain', '2026-08-05', NULL, 'Pending'),                                 -- 6  (new)
(8, 7, 'Renal Function Test', '2026-08-06', 'Creatinine 2.1 mg/dL', 'Completed');   -- 7  (new)

-- ------------------------------------------------------------
-- 2.8 Prescriptions (8 total)
-- ------------------------------------------------------------
INSERT INTO Prescription (Patient_ID, Doctor_ID, Medicine_ID, Dosage, Duration, Instructions) VALUES
(1, 1, 1, '1 tablet', '5 days', 'Take after food, twice daily'),                    -- 1
(3, 7, 3, '500mg', '30 days', 'Twice daily with meals'),                            -- 2  (doctor fixed)
(3, 7, 5, '10 units', '30 days', 'Subcutaneous, before dinner'),                    -- 3  (doctor fixed)
(4, 8, 4, '2 puffs', 'As needed', 'Use during breathing difficulty'),               -- 4  (doctor fixed)
(6, 1, 7, '5mg', '30 days', 'Once daily in the morning'),                           -- 5  (new)
(7, 9, 1, '1 tablet', 'As needed', 'Take at onset of migraine'),                    -- 6  (new)
(8, 7, 3, '500mg', '30 days', 'Twice daily with meals'),                            -- 7  (new)
(8, 7, 8, '20mg', '30 days', 'Once daily at night');                                -- 8  (new)

-- ------------------------------------------------------------
-- 2.9 Billing (6 total)
-- ------------------------------------------------------------
INSERT INTO Billing (Patient_ID, Appointment_ID, Consultation_Fee, Lab_Charge, Medicine_Charge, Room_Charge, Payment_Status) VALUES
(1, 1, 500.00, 800.00, 25.00, 0.00, 'Unpaid'),      -- 1
(3, 3, 600.00, 450.00, 850.00, 3000.00, 'Partial'), -- 2
(2, 6, 400.00, 0.00, 0.00, 0.00, 'Paid'),           -- 3  (fixed: Appointment_ID 8 -> 6, matches Patient 2's real appointment)
(6, 7, 700.00, 600.00, 50.00, 5000.00, 'Unpaid'),   -- 4  (new)
(7, 8, 550.00, 1200.00, 20.00, 0.00, 'Partial'),    -- 5  (new)
(8, 9, 650.00, 900.00, 100.00, 2500.00, 'Unpaid');  -- 6  (new)

-- ------------------------------------------------------------
-- 2.10 Insurance (6 total)
-- ------------------------------------------------------------
INSERT INTO Insurance (Patient_ID, Provider, Policy_Number, Claim_Status, Coverage) VALUES
(1, 'Star Health', 'SH-2026-00123', 'Pending', 50000.00),      -- 1
(3, 'HDFC ERGO', 'HE-2025-77821', 'Approved', 200000.00),      -- 2
(4, 'ICICI Lombard', 'IL-2026-33410', 'Pending', 100000.00),   -- 3
(6, 'LIC Health', 'LIC-2026-55012', 'Approved', 300000.00),    -- 4  (new)
(7, 'Bajaj Allianz', 'BA-2026-99087', 'Pending', 75000.00),    -- 5  (new)
(8, 'Star Health', 'SH-2026-44560', 'Approved', 150000.00);    -- 6  (new)

-- ------------------------------------------------------------
-- 2.11 Ambulance fleet (4 total)
-- ------------------------------------------------------------
INSERT INTO Ambulance (Driver_Name, Vehicle_Number, Availability, Patient_ID) VALUES
('Suresh Kumar', 'TN-01-AB-1234', 'Available', NULL),   -- 1
('Ganesh Babu', 'TN-02-CD-5678', 'On Duty', 3),         -- 2
('Rajesh Kannan', 'TN-03-EF-9012', 'On Duty', 6),       -- 3  (new)
('Mani Chandran', 'TN-04-GH-3456', 'Maintenance', NULL); -- 4  (new)

-- ------------------------------------------------------------
-- 2.12 AI Predictions (5 total)
-- ------------------------------------------------------------
INSERT INTO AI_Prediction (Patient_ID, Symptoms, Predicted_Disease, Confidence, Prediction_Date) VALUES
(1, 'Chest pain, shortness of breath', 'Angina', 82.50, '2026-08-01 09:15:00'),                          -- 1
(3, 'Fatigue, excessive thirst, blurred vision', 'Diabetic Complication Risk', 76.30, '2026-07-25 07:30:00'), -- 2
(4, 'Wheezing, shortness of breath', 'Asthma Exacerbation', 88.10, '2026-08-01 12:00:00'),                -- 3
(6, 'Chest tightness, radiating arm pain', 'Acute Coronary Syndrome', 91.40, '2026-08-05 08:45:00'),      -- 4  (new)
(8, 'Elevated creatinine, fatigue, swelling', 'Chronic Kidney Disease Progression', 79.60, '2026-08-06 09:30:00'); -- 5  (new)


-- ============================================================
-- SECTION 3: RELATIONSHIP / INTEGRITY VERIFICATION
-- Each check should return 0 for Issue_Count if the data and
-- FKs are clean. Run these after seeding to confirm integrity.
-- ============================================================

-- 3.1 Orphan check - Doctors pointing to a non-existent Department
SELECT 'Orphan Doctor->Department' AS Check_Name, COUNT(*) AS Issue_Count
FROM Doctor d
LEFT JOIN Department dept ON d.Department_ID = dept.Department_ID
WHERE d.Department_ID IS NOT NULL AND dept.Department_ID IS NULL;

-- 3.2 Orphan check - Appointments pointing to missing Patient or Doctor
SELECT 'Orphan Appointment->Patient/Doctor' AS Check_Name, COUNT(*) AS Issue_Count
FROM Appointment a
LEFT JOIN Patient p ON a.Patient_ID = p.Patient_ID
LEFT JOIN Doctor d ON a.Doctor_ID = d.Doctor_ID
WHERE p.Patient_ID IS NULL OR d.Doctor_ID IS NULL;

-- 3.3 Orphan check - Prescriptions pointing to missing Patient/Doctor/Medicine
SELECT 'Orphan Prescription->Patient/Doctor/Medicine' AS Check_Name, COUNT(*) AS Issue_Count
FROM Prescription pr
LEFT JOIN Patient p ON pr.Patient_ID = p.Patient_ID
LEFT JOIN Doctor d ON pr.Doctor_ID = d.Doctor_ID
LEFT JOIN Pharmacy m ON pr.Medicine_ID = m.Medicine_ID
WHERE p.Patient_ID IS NULL OR d.Doctor_ID IS NULL OR m.Medicine_ID IS NULL;

-- 3.4 Orphan check - Billing pointing to a missing Patient or Appointment
SELECT 'Orphan Billing->Patient/Appointment' AS Check_Name, COUNT(*) AS Issue_Count
FROM Billing b
LEFT JOIN Patient p ON b.Patient_ID = p.Patient_ID
LEFT JOIN Appointment a ON b.Appointment_ID = a.Appointment_ID
WHERE p.Patient_ID IS NULL OR (b.Appointment_ID IS NOT NULL AND a.Appointment_ID IS NULL);

-- 3.5 Row counts across every table (sanity check that seed data loaded)
SELECT 'Department' AS Table_Name, COUNT(*) AS Row_Count FROM Department
UNION ALL SELECT 'Doctor', COUNT(*) FROM Doctor
UNION ALL SELECT 'Patient', COUNT(*) FROM Patient
UNION ALL SELECT 'Appointment', COUNT(*) FROM Appointment
UNION ALL SELECT 'Admission', COUNT(*) FROM Admission
UNION ALL SELECT 'Laboratory', COUNT(*) FROM Laboratory
UNION ALL SELECT 'Pharmacy', COUNT(*) FROM Pharmacy
UNION ALL SELECT 'Prescription', COUNT(*) FROM Prescription
UNION ALL SELECT 'Billing', COUNT(*) FROM Billing
UNION ALL SELECT 'Insurance', COUNT(*) FROM Insurance
UNION ALL SELECT 'Ambulance', COUNT(*) FROM Ambulance
UNION ALL SELECT 'AI_Prediction', COUNT(*) FROM AI_Prediction;

-- 3.6 Confirm One-to-Many: each Department shows its Doctor count
SELECT dept.Department_Name, COUNT(d.Doctor_ID) AS Doctor_Count
FROM Department dept
LEFT JOIN Doctor d ON dept.Department_ID = d.Department_ID
GROUP BY dept.Department_ID, dept.Department_Name
ORDER BY Doctor_Count DESC;

-- 3.7 Confirm a live FK constraint actually blocks bad inserts
-- (uncomment to test - this INSERT should fail with a foreign key error)
-- INSERT INTO Appointment (Patient_ID, Doctor_ID, Appointment_Date, Appointment_Time, Status, Reason)
-- VALUES (9999, 9999, '2026-09-01', '09:00:00', 'Scheduled', 'Should fail - invalid FK');


-- ============================================================
-- SECTION 4: BUSINESS / REPORTING QUERIES
-- ============================================================

-- 4.1 Full patient directory with age computed from DOB
SELECT Patient_ID, CONCAT(First_Name, ' ', Last_Name) AS Full_Name, Gender,
       TIMESTAMPDIFF(YEAR, DOB, CURDATE()) AS Age, Blood_Group, Phone
FROM Patient
ORDER BY Full_Name;

-- 4.2 Upcoming appointments with patient & doctor names
SELECT a.Appointment_ID, CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient,
       d.Doctor_Name, dept.Department_Name, a.Appointment_Date,
       a.Appointment_Time, a.Status, a.Reason
FROM Appointment a
JOIN Patient p        ON a.Patient_ID = p.Patient_ID
JOIN Doctor d         ON a.Doctor_ID = d.Doctor_ID
JOIN Department dept  ON d.Department_ID = dept.Department_ID
WHERE a.Appointment_Date >= CURDATE()
ORDER BY a.Appointment_Date, a.Appointment_Time;

-- 4.3 A specific doctor's full daily schedule (example: Doctor_ID = 4)
SELECT a.Appointment_Time, CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient,
       a.Reason, a.Status
FROM Appointment a
JOIN Patient p ON a.Patient_ID = p.Patient_ID
WHERE a.Doctor_ID = 4 AND a.Appointment_Date = '2026-08-04'
ORDER BY a.Appointment_Time;

-- 4.4 Currently admitted (in-patient) list - Discharge_Date IS NULL
SELECT ad.Admission_ID, CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient,
       ad.Ward, ad.Room_No, ad.Bed_No, ad.Admission_Date,
       DATEDIFF(CURDATE(), ad.Admission_Date) AS Days_Admitted
FROM Admission ad
JOIN Patient p ON ad.Patient_ID = p.Patient_ID
WHERE ad.Discharge_Date IS NULL;

-- 4.5 Pending lab tests
SELECT lab.Lab_ID, CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient,
       d.Doctor_Name, lab.Test_Name, lab.Status
FROM Laboratory lab
JOIN Patient p ON lab.Patient_ID = p.Patient_ID
JOIN Doctor d  ON lab.Doctor_ID = d.Doctor_ID
WHERE lab.Status = 'Pending';

-- 4.6 Full prescription detail (patient + doctor + medicine)
SELECT pr.Prescription_ID, CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient,
       d.Doctor_Name, m.Medicine_Name, pr.Dosage, pr.Duration, pr.Instructions
FROM Prescription pr
JOIN Patient p  ON pr.Patient_ID = p.Patient_ID
JOIN Doctor d   ON pr.Doctor_ID = d.Doctor_ID
JOIN Pharmacy m ON pr.Medicine_ID = m.Medicine_ID
ORDER BY pr.Prescription_ID;

-- 4.7 Most-prescribed medicines
SELECT m.Medicine_Name, COUNT(pr.Prescription_ID) AS Times_Prescribed
FROM Prescription pr
JOIN Pharmacy m ON pr.Medicine_ID = m.Medicine_ID
GROUP BY m.Medicine_ID, m.Medicine_Name
ORDER BY Times_Prescribed DESC;

-- 4.8 Medicines low in stock or expiring within 60 days
SELECT Medicine_Name, Stock, Expiry_Date,
       CASE WHEN Stock < 30 THEN 'Low Stock' ELSE 'OK' END AS Stock_Flag,
       CASE WHEN Expiry_Date <= DATE_ADD(CURDATE(), INTERVAL 60 DAY) THEN 'Expiring Soon' ELSE 'OK' END AS Expiry_Flag
FROM Pharmacy
WHERE Stock < 30 OR Expiry_Date <= DATE_ADD(CURDATE(), INTERVAL 60 DAY);

-- 4.9 Outstanding (unpaid/partial) bills per patient
SELECT CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient,
       SUM(b.Total_Amount) AS Total_Billed, b.Payment_Status
FROM Billing b
JOIN Patient p ON b.Patient_ID = p.Patient_ID
WHERE b.Payment_Status != 'Paid'
GROUP BY p.Patient_ID, b.Payment_Status
ORDER BY Total_Billed DESC;

-- 4.10 Revenue collected by department (via doctor -> appointment -> billing)
SELECT dept.Department_Name, SUM(b.Total_Amount) AS Revenue
FROM Billing b
JOIN Appointment a    ON b.Appointment_ID = a.Appointment_ID
JOIN Doctor d         ON a.Doctor_ID = d.Doctor_ID
JOIN Department dept  ON d.Department_ID = dept.Department_ID
GROUP BY dept.Department_ID, dept.Department_Name
ORDER BY Revenue DESC;

-- 4.11 Insurance claims by status
SELECT CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient,
       i.Provider, i.Policy_Number, i.Claim_Status, i.Coverage
FROM Insurance i
JOIN Patient p ON i.Patient_ID = p.Patient_ID
ORDER BY i.Claim_Status;

-- 4.12 Patients with NO insurance on file (useful for outreach)
SELECT CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient, p.Phone
FROM Patient p
LEFT JOIN Insurance i ON p.Patient_ID = i.Patient_ID
WHERE i.Insurance_ID IS NULL;

-- 4.13 Ambulance fleet status
SELECT Ambulance_ID, Driver_Name, Vehicle_Number, Availability,
       Patient_ID AS Currently_Assigned_Patient
FROM Ambulance;

-- 4.14 AI predictions with high confidence (>= 80%), most recent first
SELECT CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient,
       ai.Symptoms, ai.Predicted_Disease, ai.Confidence, ai.Prediction_Date
FROM AI_Prediction ai
JOIN Patient p ON ai.Patient_ID = p.Patient_ID
WHERE ai.Confidence >= 80
ORDER BY ai.Prediction_Date DESC;

-- 4.15 Complete medical timeline for one patient (example: Patient_ID = 3)
--      Appointments, admissions, and lab tests in one feed
SELECT 'Appointment' AS Event_Type, a.Appointment_Date AS Event_Date,
       CONCAT(d.Doctor_Name, ' - ', a.Reason) AS Details
FROM Appointment a JOIN Doctor d ON a.Doctor_ID = d.Doctor_ID
WHERE a.Patient_ID = 3
UNION ALL
SELECT 'Admission', DATE(ad.Admission_Date),
       CONCAT(ad.Ward, ' Room ', ad.Room_No)
FROM Admission ad
WHERE ad.Patient_ID = 3
UNION ALL
SELECT 'Lab Test', lab.Test_Date, CONCAT(lab.Test_Name, ' - ', lab.Status)
FROM Laboratory lab
WHERE lab.Patient_ID = 3
ORDER BY Event_Date;
