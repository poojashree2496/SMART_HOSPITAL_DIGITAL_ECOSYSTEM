USE SmartDigitalHospital;

-- ============================================================
-- SMART DIGITAL HOSPITAL ECOSYSTEM
-- PROJECT QUERIES
-- ============================================================


-- 1. Display all departments
SELECT * FROM Department;


-- 2. Display all doctors with their departments
SELECT 
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    d.Experience,
    dep.DepartmentName
FROM Doctor d
JOIN Department dep
    ON d.DepartmentID = dep.DepartmentID;


-- 3. Display all patients
SELECT * FROM Patient;


-- 4. Display patients with their blood groups
SELECT
    PatientID,
    CONCAT(FirstName, ' ', LastName) AS PatientName,
    Gender,
    BloodGroup,
    Phone,
    Medical_History
FROM Patient;


-- 5. Display all appointments with patient and doctor details
SELECT
    a.AppointmentID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    a.AppointmentDate,
    a.AppointmentTime,
    a.Status,
    a.Reason
FROM Appointment a
JOIN Patient p
    ON a.PatientID = p.PatientID
JOIN Doctor d
    ON a.DoctorID = d.DoctorID;


-- 6. Count total patients
SELECT COUNT(*) AS TotalPatients
FROM Patient;


-- 7. Count total doctors
SELECT COUNT(*) AS TotalDoctors
FROM Doctor;


-- 8. Count patients by gender
SELECT
    Gender,
    COUNT(*) AS PatientCount
FROM Patient
GROUP BY Gender;


-- 9. Count doctors in each department
SELECT
    dep.DepartmentName,
    COUNT(d.DoctorID) AS NumberOfDoctors
FROM Department dep
LEFT JOIN Doctor d
    ON dep.DepartmentID = d.DepartmentID
GROUP BY dep.DepartmentID, dep.DepartmentName;


-- 10. Appointment status summary
SELECT
    Status,
    COUNT(*) AS TotalAppointments
FROM Appointment
GROUP BY Status;


-- 11. Most common medical histories
SELECT
    Medical_History,
    COUNT(*) AS NumberOfPatients
FROM Patient
GROUP BY Medical_History
ORDER BY NumberOfPatients DESC;


-- 12. Display available doctors
SELECT
    DoctorID,
    CONCAT(FirstName, ' ', LastName) AS DoctorName,
    Specialization,
    Availability
FROM Doctor
WHERE Availability = 'Available';


-- 13. Display available rooms
SELECT
    RoomID,
    RoomNumber,
    RoomType,
    ChargesPerDay
FROM Room
WHERE Availability = 'Available';


-- 14. Display medicines with low stock
SELECT
    MedicineID,
    MedicineName,
    Stock,
    Price
FROM Pharmacy
WHERE Stock < 25
ORDER BY Stock ASC;


-- 15. Find the most expensive medicines
SELECT
    MedicineName,
    Price
FROM Pharmacy
ORDER BY Price DESC
LIMIT 10;


-- 16. Display patient admission details
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
    ON a.RoomID = r.RoomID;


-- 17. Display laboratory test details
SELECT
    l.LabID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    l.TestName,
    l.TestDate,
    l.Result,
    l.Status
FROM Laboratory l
JOIN Patient p
    ON l.PatientID = p.PatientID;


-- 18. Display prescription details
SELECT
    pr.PrescriptionID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    ph.MedicineName,
    pr.Dosage,
    pr.Duration,
    pr.Instructions
FROM Prescription pr
JOIN Patient p
    ON pr.PatientID = p.PatientID
JOIN Doctor d
    ON pr.DoctorID = d.DoctorID
JOIN Pharmacy ph
    ON pr.MedicineID = ph.MedicineID;


-- 19. Total billing amount
SELECT
    SUM(TotalAmount) AS TotalHospitalRevenue
FROM Billing;


-- 20. Billing summary by payment status
SELECT
    PaymentStatus,
    COUNT(*) AS NumberOfBills,
    SUM(TotalAmount) AS TotalAmount
FROM Billing
GROUP BY PaymentStatus;


-- 21. Patients having insurance
SELECT
    i.InsuranceID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    i.InsuranceProvider,
    i.PolicyNumber,
    i.CoverageAmount,
    i.ClaimStatus
FROM Insurance i
JOIN Patient p
    ON i.PatientID = p.PatientID;


-- 22. AI prediction results
SELECT
    ai.PredictionID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    ai.PredictedDisease,
    ai.Confidence,
    ai.PredictionDate
FROM AI_Prediction ai
JOIN Patient p
    ON ai.PatientID = p.PatientID
ORDER BY ai.Confidence DESC;


-- 23. Patients with high AI prediction confidence
SELECT
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    ai.PredictedDisease,
    ai.Confidence
FROM AI_Prediction ai
JOIN Patient p
    ON ai.PatientID = p.PatientID
WHERE ai.Confidence >= 90
ORDER BY ai.Confidence DESC;


-- 24. Average doctor experience
SELECT
    AVG(Experience) AS AverageDoctorExperience
FROM Doctor;


-- 25. Doctors with more than 10 years of experience
SELECT
    DoctorID,
    CONCAT(FirstName, ' ', LastName) AS DoctorName,
    Specialization,
    Experience
FROM Doctor
WHERE Experience > 10
ORDER BY Experience DESC;


-- 26. Number of laboratory tests by status
SELECT
    Status,
    COUNT(*) AS NumberOfTests
FROM Laboratory
GROUP BY Status;


-- 27. Number of prescriptions per medicine
SELECT
    ph.MedicineName,
    COUNT(pr.PrescriptionID) AS PrescriptionCount
FROM Pharmacy ph
LEFT JOIN Prescription pr
    ON ph.MedicineID = pr.MedicineID
GROUP BY ph.MedicineID, ph.MedicineName
ORDER BY PrescriptionCount DESC;


-- 28. Patients with medical records
SELECT
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    mr.Diagnosis,
    mr.Treatment,
    mr.RecordDate
FROM Patient p
JOIN MedicalRecord mr
    ON p.PatientID = mr.PatientID
ORDER BY mr.RecordDate DESC;


-- 29. Total staff by role
SELECT
    Role,
    COUNT(*) AS NumberOfStaff
FROM Staff
GROUP BY Role
ORDER BY NumberOfStaff DESC;


-- 30. Hospital dashboard summary
SELECT
    (SELECT COUNT(*) FROM Patient) AS TotalPatients,
    (SELECT COUNT(*) FROM Doctor) AS TotalDoctors,
    (SELECT COUNT(*) FROM Appointment) AS TotalAppointments,
    (SELECT COUNT(*) FROM Admission) AS TotalAdmissions,
    (SELECT COUNT(*) FROM Laboratory) AS TotalLabTests,
    (SELECT COUNT(*) FROM Prescription) AS TotalPrescriptions,
    (SELECT COUNT(*) FROM Billing) AS TotalBills,
    (SELECT COUNT(*) FROM Staff) AS TotalStaff;