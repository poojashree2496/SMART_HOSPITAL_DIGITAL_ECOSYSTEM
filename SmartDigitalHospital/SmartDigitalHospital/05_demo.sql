USE SmartDigitalHospital;


-- ============================================================
-- SMART DIGITAL HOSPITAL ECOSYSTEM
-- FINAL PROJECT DEMONSTRATION
-- ============================================================


-- 1. HOSPITAL OVERVIEW
-- Shows the total records in major hospital modules

SELECT
    (SELECT COUNT(*) FROM Patient) AS TotalPatients,
    (SELECT COUNT(*) FROM Doctor) AS TotalDoctors,
    (SELECT COUNT(*) FROM Department) AS TotalDepartments,
    (SELECT COUNT(*) FROM Appointment) AS TotalAppointments,
    (SELECT COUNT(*) FROM Admission) AS TotalAdmissions,
    (SELECT COUNT(*) FROM Laboratory) AS TotalLabTests,
    (SELECT COUNT(*) FROM Prescription) AS TotalPrescriptions,
    (SELECT COUNT(*) FROM Billing) AS TotalBills;


-- ============================================================
-- 2. PATIENT + DOCTOR + DEPARTMENT
-- Shows the hospital's appointment management
-- ============================================================

SELECT
    a.AppointmentID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    dep.DepartmentName,
    a.AppointmentDate,
    a.AppointmentTime,
    a.Status
FROM Appointment a
JOIN Patient p
    ON a.PatientID = p.PatientID
JOIN Doctor d
    ON a.DoctorID = d.DoctorID
JOIN Department dep
    ON d.DepartmentID = dep.DepartmentID
LIMIT 15;


-- ============================================================
-- 3. DOCTORS BY DEPARTMENT
-- ============================================================

SELECT
    dep.DepartmentName,
    COUNT(d.DoctorID) AS NumberOfDoctors
FROM Department dep
LEFT JOIN Doctor d
    ON dep.DepartmentID = d.DepartmentID
GROUP BY dep.DepartmentID, dep.DepartmentName
ORDER BY NumberOfDoctors DESC;


-- ============================================================
-- 4. APPOINTMENT STATUS ANALYSIS
-- ============================================================

SELECT
    Status,
    COUNT(*) AS TotalAppointments
FROM Appointment
GROUP BY Status
ORDER BY TotalAppointments DESC;


-- ============================================================
-- 5. TOP MEDICAL CONDITIONS
-- ============================================================

SELECT
    Diagnosis,
    COUNT(*) AS NumberOfCases
FROM MedicalRecord
GROUP BY Diagnosis
ORDER BY NumberOfCases DESC;


-- ============================================================
-- 6. PHARMACY STOCK ALERT
-- Shows medicines with low stock
-- ============================================================

SELECT
    MedicineID,
    MedicineName,
    Manufacturer,
    Stock,
    Price,
    ExpiryDate
FROM Pharmacy
WHERE Stock < 25
ORDER BY Stock ASC;


-- ============================================================
-- 7. PATIENT ADMISSION DETAILS
-- ============================================================

SELECT
    a.AdmissionID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    r.RoomNumber,
    r.RoomType,
    r.ChargesPerDay,
    a.AdmissionDate,
    a.DischargeDate
FROM Admission a
JOIN Patient p
    ON a.PatientID = p.PatientID
JOIN Room r
    ON a.RoomID = r.RoomID
LIMIT 15;


-- ============================================================
-- 8. BILLING ANALYSIS
-- ============================================================

SELECT
    PaymentStatus,
    COUNT(*) AS NumberOfBills,
    SUM(TotalAmount) AS TotalBilled,
    SUM(InsuranceCovered) AS InsuranceCoverage,
    SUM(AmountToPay) AS AmountToCollect
FROM Billing
GROUP BY PaymentStatus;


-- ============================================================
-- 9. AI PREDICTION ANALYSIS
-- Shows high-confidence AI predictions
-- ============================================================

SELECT
    ai.PredictionID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    ai.PredictedDisease,
    ai.Confidence,
    ai.PredictionDate
FROM AI_Prediction ai
JOIN Patient p
    ON ai.PatientID = p.PatientID
WHERE ai.Confidence >= 90
ORDER BY ai.Confidence DESC;


-- ============================================================
-- 10. LABORATORY STATUS
-- ============================================================

SELECT
    Status,
    COUNT(*) AS TotalTests
FROM Laboratory
GROUP BY Status;


-- ============================================================
-- 11. INSURANCE CLAIM ANALYSIS
-- ============================================================

SELECT
    ClaimStatus,
    COUNT(*) AS NumberOfClaims,
    SUM(CoverageAmount) AS TotalCoverage
FROM Insurance
GROUP BY ClaimStatus;


-- ============================================================
-- 12. HOSPITAL REVENUE
-- ============================================================

SELECT
    SUM(TotalAmount) AS TotalHospitalBilling,
    SUM(InsuranceCovered) AS TotalInsuranceCoverage,
    SUM(AmountToPay) AS TotalAmountToCollect,
    AVG(TotalAmount) AS AverageBill
FROM Billing;


-- ============================================================
-- 13. VIEW DEMONSTRATION
-- ============================================================

SELECT *
FROM PatientAppointmentView
LIMIT 10;


-- ============================================================
-- 14. STORED PROCEDURE DEMONSTRATION
-- ============================================================

CALL GetPatientDetails(1);


-- ============================================================
-- 15. DOCTOR SEARCH USING STORED PROCEDURE
-- ============================================================

CALL GetDoctorsByDepartment(1);


-- ============================================================
-- 16. PATIENT BILL USING STORED PROCEDURE
-- ============================================================

CALL GetPatientBills(1);