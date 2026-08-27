USE SmartDigitalHospital;

-- ============================================================
-- SMART DIGITAL HOSPITAL ECOSYSTEM
-- ADVANCED DATABASE FEATURES
-- ============================================================


-- ============================================================
-- 1. VIEW: PATIENT APPOINTMENT DETAILS
-- ============================================================

CREATE OR REPLACE VIEW PatientAppointmentView AS
SELECT
    a.AppointmentID,
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.Gender,
    p.BloodGroup,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    dep.DepartmentName,
    a.AppointmentDate,
    a.AppointmentTime,
    a.Status,
    a.Reason
FROM Appointment a
JOIN Patient p
    ON a.PatientID = p.PatientID
JOIN Doctor d
    ON a.DoctorID = d.DoctorID
JOIN Department dep
    ON d.DepartmentID = dep.DepartmentID;


-- ============================================================
-- 2. VIEW: PATIENT MEDICAL SUMMARY
-- ============================================================

CREATE OR REPLACE VIEW PatientMedicalSummary AS
SELECT
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.BloodGroup,
    p.Medical_History,
    mr.Diagnosis,
    mr.Treatment,
    mr.RecordDate
FROM Patient p
LEFT JOIN MedicalRecord mr
    ON p.PatientID = mr.PatientID;


-- ============================================================
-- 3. VIEW: BILLING SUMMARY
-- ============================================================

CREATE OR REPLACE VIEW BillingSummary AS
SELECT
    b.BillID,
    b.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    b.ConsultationFee,
    b.LabCharge,
    b.MedicineCharge,
    b.RoomCharge,
    b.TotalAmount,
    b.InsuranceCovered,
    b.AmountToPay,
    b.PaymentStatus,
    b.BillDate
FROM Billing b
JOIN Patient p
    ON b.PatientID = p.PatientID;


-- ============================================================
-- 4. VIEW: AI PREDICTION REPORT
-- ============================================================

CREATE OR REPLACE VIEW AIPredictionReport AS
SELECT
    ai.PredictionID,
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    ai.Symptoms,
    ai.PredictedDisease,
    ai.Confidence,
    ai.PredictionDate
FROM AI_Prediction ai
JOIN Patient p
    ON ai.PatientID = p.PatientID;


-- ============================================================
-- 5. VIEW: DOCTOR DEPARTMENT DETAILS
-- ============================================================

CREATE OR REPLACE VIEW DoctorDepartmentView AS
SELECT
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    d.Experience,
    d.Availability,
    dep.DepartmentName,
    dep.Location
FROM Doctor d
JOIN Department dep
    ON d.DepartmentID = dep.DepartmentID;


-- ============================================================
-- 6. STORED PROCEDURE: GET PATIENT DETAILS
-- ============================================================

DELIMITER //

CREATE PROCEDURE GetPatientDetails(IN p_id INT)
BEGIN
    SELECT
        p.PatientID,
        CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
        p.Gender,
        p.DOB,
        p.BloodGroup,
        p.Phone,
        p.Email,
        p.Medical_History,
        mr.Diagnosis,
        mr.Treatment,
        mr.RecordDate
    FROM Patient p
    LEFT JOIN MedicalRecord mr
        ON p.PatientID = mr.PatientID
    WHERE p.PatientID = p_id;
END //

DELIMITER ;


-- ============================================================
-- 7. STORED PROCEDURE: GET DOCTORS BY DEPARTMENT
-- ============================================================

DELIMITER //

CREATE PROCEDURE GetDoctorsByDepartment(IN dept_id INT)
BEGIN
    SELECT
        d.DoctorID,
        CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
        d.Specialization,
        d.Experience,
        d.Availability
    FROM Doctor d
    WHERE d.DepartmentID = dept_id
    ORDER BY d.Experience DESC;
END //

DELIMITER ;


-- ============================================================
-- 8. STORED PROCEDURE: PATIENT BILL SUMMARY
-- ============================================================

DELIMITER //

CREATE PROCEDURE GetPatientBills(IN p_id INT)
BEGIN
    SELECT
        BillID,
        BillDate,
        TotalAmount,
        InsuranceCovered,
        AmountToPay,
        PaymentStatus
    FROM Billing
    WHERE PatientID = p_id
    ORDER BY BillDate DESC;
END //

DELIMITER ;


-- ============================================================
-- 9. TRIGGER: PREVENT NEGATIVE PHARMACY STOCK
-- ============================================================

DELIMITER //

CREATE TRIGGER CheckMedicineStock
BEFORE UPDATE ON Pharmacy
FOR EACH ROW
BEGIN
    IF NEW.Stock < 0 THEN
        SET NEW.Stock = 0;
    END IF;
END //

DELIMITER ;


-- ============================================================
-- 10. TRIGGER: CALCULATE BILL TOTAL
-- ============================================================

DELIMITER //

CREATE TRIGGER CalculateBillAmount
BEFORE INSERT ON Billing
FOR EACH ROW
BEGIN

    SET NEW.TotalAmount =
        NEW.ConsultationFee +
        NEW.LabCharge +
        NEW.MedicineCharge +
        NEW.RoomCharge;

    SET NEW.AmountToPay =
        NEW.TotalAmount -
        NEW.InsuranceCovered;

    IF NEW.AmountToPay < 0 THEN
        SET NEW.AmountToPay = 0;
    END IF;

END //

DELIMITER ;


-- ============================================================
-- TEST VIEWS
-- ============================================================

SELECT * FROM PatientAppointmentView
LIMIT 10;

SELECT * FROM PatientMedicalSummary
LIMIT 10;

SELECT * FROM BillingSummary
LIMIT 10;

SELECT * FROM AIPredictionReport
LIMIT 10;

SELECT * FROM DoctorDepartmentView
LIMIT 10;


-- ============================================================
-- TEST STORED PROCEDURES
-- ============================================================

CALL GetPatientDetails(1);

CALL GetDoctorsByDepartment(1);

CALL GetPatientBills(1);