/*========================================
Data Exploration & Schema Familiarisation
========================================*/

--List all unique values in the claim_status column to understand what statuses exist in the dataset.
	SELECT 
		DISTINCT claim_status,
		COUNT(*) AS claim_count
	FROM claims
	GROUP BY claim_status
	ORDER BY claim_count DESC


--Count the total number of records in each of the five tables: claims, admissions, doctors, insurance, and patients.
	
	--"claims" total records
	SELECT 'claims' AS table_name,
		COUNT(*) AS total_records 
	FROM claims
	UNION ALL
	--"admissions" total records
	SELECT 'admissions',
		COUNT(*) 
	FROM admissions
	UNION ALL
	--"doctors" total records
	SELECT 'doctors',
		COUNT(*) 
	FROM doctors
	UNION ALL
	--"insurance" total records
	SELECT 'insurance',
		COUNT(*)
	FROM insurance
	UNION ALL
	--"patients" total rescord
	SELECT 'patients',
		COUNT(*) 
	FROM patients


--Find the earliest and latest claim_date in the claims table to understand the date range of the dataset.
	SELECT 
		MAX(claim_date) AS latest_claim_date,
		MIN(claim_date) AS earliest_claim_date,
		DATEDIFF(YEAR, MIN(claim_date), MAX(claim_date)) AS date_range_of_dataset
	FROM claims


--Show each distinct admission_type and the count of admissions for each type.
	SELECT 
		DISTINCT admission_type,
		COUNT(*) AS total_admissions,
		ROUND((COUNT(*) *100.0 / SUM(COUNT(*)) OVER()), 2) AS percentage_of_total
	FROM admissions
	GROUP BY admission_type
	ORDER BY total_admissions DESC


--Check for claims where billed_amount, allowed_amount, or paid_amount is NULL or zero and count how many exist
	SELECT
		SUM(CASE WHEN billed_amount IS NULL OR billed_amount = 0 THEN 1 ELSE 0 END) AS bad_billed_amount,
		SUM(CASE WHEN allowed_amount IS NULL OR allowed_amount = 0 THEN 1 ELSE 0 END) AS bad_allowed_amount,
		SUM(CASE WHEN paid_amount IS NULL OR paid_amount = 0 THEN 1 ELSE 0 END) AS bad_paid_amount,
		COUNT(*) AS total_claims
	FROM claims


--Identify any claims that are linked to patient IDs that do not exist in the patients table.
	SELECT
		c.claim_id,
		p.patient_id
	FROM claims AS c
	LEFT JOIN patients AS p
	ON c.patient_id = p.patient_id
	WHERE p.patient_id IS NULL


--Flag each claim as 'Complete' if all three financial fields are populated, else 'Incomplete', and count how many fall into each group.
	SELECT
		CASE 
			WHEN  
				billed_amount > 0 AND 
				allowed_amount > 0 AND
				paid_amount > 0 
			THEN 'complete'
			ELSE 'Incomplete' 
			END AS completeness_flag,
		COUNT(*) AS total_claims,
		ROUND(COUNT(*)*100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage_of_total
	FROM claims 
	GROUP BY
	CASE 
		WHEN 
			billed_amount > 0 AND
			allowed_amount > 0 AND
			paid_amount > 0 
		THEN 'complete'
		ELSE 'Incomplete' 
		END


--Find how many doctors have no associated claims in the claims table.
	SELECT 
		d.doctor_id,
		c.claim_id
	FROM doctors AS d
	LEFT JOIN claims AS c
	ON d.doctor_id = c.doctor_id
	WHERE c.doctor_id IS NULL


--Count the number of claims per year and calculate what percentage of total claims each year represents.
	SELECT 
		YEAR(claim_date) AS claim_year,
		COUNT(claim_id) AS total_claims,
		ROUND(COUNT(claim_id)*100.0/SUM(COUNT(claim_id)) OVER(), 2) AS percentage_of_total
	FROM claims
	GROUP BY YEAR(claim_date)
	ORDER BY claim_year DESC


--For each claim, show the total number of claims associated with the same insurer to identify which insurers dominate.
	SELECT
		c.insurance_id,
		COUNT(c.insurance_id) AS total_insurance_claims,
		i.company_name
	FROM claims AS c
	INNER JOIN insurance AS i
	ON i.insurance_id = c.insurance_id
	GROUP BY c.insurance_id, i.company_name
	ORDER BY total_insurance_claims DESC