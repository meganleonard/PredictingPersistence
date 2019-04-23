/** 
Machine Learning Project

Written by: Megan Leonard
Date last updated: 2/25/2019
Research Request(s): N/A

Comments: 

Training Set 
Fall 2018 to Spring 2019
-- Outcome Variable: Persist yes/no
-- Predictor Variables: Leakage variables 


***/ 

SELECT DISTINCT
	ce.STC_TERM,
	ce.STC_PERSON_ID,

------------------------ Demographics ------------------------
	CASE WHEN ce.gender = 'F' THEN 0
		 WHEN ce.gender = 'M' THEN 1
		 ELSE NULL END AS Gender,
	pe.ethnicity AS Ethnicity,
	CASE WHEN pe.Ethnicity LIKE '%Latino%' THEN 1 ELSE 0 END AS Latino,
	CASE WHEN pe.URM = 'URM' THEN 1 ELSE 0 END AS URM,
	-- AS Age,
	-- AS CollegeAge,

------------------------ Location ------------------------
	LEFT (pa.ZIP,5) AS ZipCode,
	CASE WHEN z.PO_NAME IS NULL THEN 0 ELSE 1 END AS LocalStudent,
	CASE WHEN z.CountyLoc IS NULL THEN 'Outside SC County' ELSE z.CountyLoc END AS CountyLoc,
	CASE WHEN z.CountyLoc = 'North County' THEN 1
		 WHEN z.CountyLoc = 'South County' THEN 0
		 ELSE NULL END AS CountyLocNum, 
	CASE WHEN z.PO_NAME IS NULL THEN 'Outside SC County' ELSE z.PO_NAME END AS SCCity,


------------------------ Education Goal/Major/CAP ------------------------
	CASE WHEN eg.StudentID IS NOT NULL THEN 1 ELSE 0 END AS HasEdGoal,
	eg.VAL_EXTERNAL_REPRESENTATION AS EducationGoal,
	eg.EducationGoal AS EducationGoalCoded,
	CASE eg.TransferEdGoal
		 WHEN 'Not' THEN 0 
		 WHEN 'Transfer' THEN 1
		 ELSE NULL
		 END AS TransferEdGoal,
	-- AS CAP,
	-- AS Major,
	-- AS STEMMajor,


------------------------ Special Populations ------------------------
	CASE WHEN eops.STUDENT_ID IS NOT NULL THEN 1
		 WHEN eops.STUDENT_ID IS NULL THEN 0
		 ELSE NULL 
		 END AS EOPSEver,
	CASE WHEN vet.ID IS NOT NULL THEN 1
		 WHEN vet.ID IS NULL THEN 0
		 ELSE NULL 
		 END AS VeteranStatus,
	CASE WHEN ds.DSPS_ID IS NOT NULL THEN 1
		 ELSE 0 
		 END AS DisabilityEver,
	CASE WHEN fy.STUDENTS_ID IS NOT NULL THEN 1 
		 WHEN fy.STUDENTS_ID IS NULL THEN 0
		 ELSE NULL 
		 END AS FosterYouthStatus,
	fg.FirstGen AS FirstGenerationStatus,
	res.[RES_DESC] AS ResidencyStatus,
	CASE res.RES_DESC
		 WHEN 'In State' THEN 1
		 WHEN NULL THEN NULL
		 ELSE 0 
		 END AS InStateStatus,
	CASE WHEN pell.SA_STUDENT_ID IS NOT NULL THEN 1
		 WHEN pell.SA_STUDENT_ID IS NULL THEN 0 
		 ELSE NULL 
		 END AS PellGrantElgCoded,
	CASE WHEN bog.SA_STUDENT_ID IS NOT NULL THEN 1
		 WHEN bog.SA_STUDENT_ID IS NULL THEN 0 
		 ELSE NULL 
		 END AS BOGGrantElgCoded,
	CASE WHEN bog.SA_STUDENT_ID IS NOT NULL OR pell.SA_STUDENT_ID IS NOT NULL THEN 1
		 ELSE 0
		 END AS LowIncome,


------------------------ Fall Enrollment Info ------------------------
	CASE WHEN ce.STC_TERM = ft.TERMS_ID THEN 1 ELSE 0 END AS FirstTerm,
	CASE WHEN ce.Credits >= 12 THEN 1 ELSE 0 END AS FTPTStatus,
	CASE WHEN ce.Credits >= 15 THEN 1 ELSE 0 END AS FifteenUnitsorMore,
	TotalUnits AS UnitsTaking,
	-- AS NumTransferrableUnitsTaking,
	-- AS SuccessRate, -----------------> when do we want to run this?
	-- AS CompletionRate, -----------------> when do we want to run this?
	ce.TakingMathCourse AS MathCourse,
	ce.TakingEnglCourse AS EnglCourse,
	ce.TakingArtCourse AS ArtCourse,
	ce.TakingPECourse AS PECourse,
	ce.TakingTransferMath AS TransferMathCourse,
	ce.TakingTransferEnglish AS TransferEnglCourse,
	-- AS ArtOnly,
	-- AS PEOnly,
	ce.TakingOLCourse AS TakingOLCourse,
	ce.TakingWCCourse AS TakingWCCourse,
	-- AS OLOnly,
	-- AS WCOnly,
	-- AS MCOnly,

------------------------ General Cabrillo Info ------------------------
	cf.CumulativeCreditsEarned AS TotalUnitsEarned,
	cf.CumulativeCreditsAttempted AS TotalUnitsAttempted,
	-- cf. AS TransferrableUnitsEarned,
	-- cf. AS TransferrableUnitsAttempted,
	-- cf. AS NumTerms,
	-- cf. AS NumPrimaryTerms,
	-- cf. AS NumSecondaryTerms,
	cf.CompletedTransferMath AS TransferMathCMP,
	cf.CompletedTransferEnglish AS TransferEnglCMP,
	gpa.GPA AS CumulativeGPA,
	cf.StudentSuccessRate AS CumulativeSuccessRate,
	cf.StudentCompletionRate AS CumulativeCompletionRate,


------------------------ Outcome Variable ------------------------
	CASE WHEN b.STC_PERSON_ID IS NULL THEN 0 ELSE 1 END AS SpringEnrolled
	
	FROM
		(SELECT 
			ce.stc_term,
			ce.stc_person_id,
			ce.gender,
			CASE WHEN ce.SEC_LOCATION = 'OL' THEN 1 ELSE 0 END AS TakingOLCourse,
			CASE WHEN ce.SEC_LOCATION IN ('WC','WA') THEN 1 ELSE 0 END AS TakingWCCourse,
			CASE WHEN ce.STC_SUBJECT = 'ENGL' THEN 1 ELSE 0 END AS TakingEnglCourse,
			CASE WHEN ce.STC_SUBJECT = 'Math' THEN 1 ELSE 0 END AS TakingMathCourse,
			CASE WHEN ce.STC_SUBJECT = 'Art' THEN 1 ELSE 0 END AS TakingArtCourse,
			CASE WHEN ce.STC_SUBJECT = 'Kin' THEN 1 ELSE 0 END AS TakingPECourse,
			CASE WHEN STC_COURSE_NAME IN ('ENGL-1A') THEN 1 ELSE 0 END AS TakingTransferEnglish,
			CASE WHEN STC_COURSE_NAME IN ('Math-5A') THEN 1 ELSE 0 END AS TakingTransferMath,
			SUM(stc_cred) AS Credits
			FROM 
				datatel.dbo.FACTBOOK_CoreEnrollment_View ce
				WHERE ce.stc_term = '2018FA'
				GROUP BY ce.stc_term, ce.stc_person_id, ce.gender, STC_COURSE_NAME
				------------------------------------------------------------ take out public safety
		) ce     ---------------------------------------> pulls Fall 2018 data only
		LEFT JOIN 
		(SELECT 
			ce.stc_person_id,
			SUM(stc_cred) AS CumulativeCreditsAttempted,
			SUM(STC_CMPL_CRED) AS CumulativeCreditsEarned,
			CASE WHEN STC_COURSE_NAME IN ('ENGL-1A') AND SUCCESS = 1 THEN 1 ELSE 0 END AS CompletedTransferEnglish,
			CASE WHEN STC_COURSE_NAME IN ('Math-5A') AND SUCCESS = 1 THEN 1 ELSE 0 END AS CompletedTransferMath,
			CASE WHEN SUM(ce.ENROLLMENT) = 0 THEN 0.00 
				 WHEN SUM(ce.ENROLLMENT)  = NULL THEN NULL 
				 WHEN SUM(ce.ENROLLMENT)  > 0 THEN CAST(CAST(SUM(ce.Success) AS decimal(10, 4)) / CAST(SUM(ce.Enrollment) AS decimal(10, 4)) AS decimal(10, 4)) 
				 END AS StudentSuccessRate,
			CASE WHEN SUM(ce.ENROLLMENT) = 0 THEN 0.00 
				 WHEN SUM(ce.ENROLLMENT)  = NULL THEN NULL 
				 WHEN SUM(ce.ENROLLMENT)  > 0 THEN CAST(CAST(SUM(ce.COMPLETION) AS decimal(10, 4)) / CAST(SUM(ce.Enrollment) AS decimal(10, 4)) AS decimal(10, 4)) 
				 END AS StudentCompletionRate
			FROM 
				datatel.dbo.FACTBOOK_CoreEnrollment_View ce
				GROUP BY ce.stc_person_id, success, STC_COURSE_NAME
		) cf ON cf.STC_PERSON_ID = ce.STC_PERSON_ID -------------> pulls all Cabrillo data
		LEFT JOIN 
		(SELECT 
			a.STC_PERSON_ID AS StudentID, 
			t.TERMS_ID
			FROM 
				(SELECT 
					[STC_PERSON_ID],
					MIN ([TermID_MIS4]) AS fterm     
					FROM 
						[datatel].[dbo].[FACTBOOK_CoreEnrollment_View]
					GROUP BY 
						[STC_PERSON_ID]
				) a
				LEFT JOIN 
				[datatel].[dbo].[Terms_View] t ON t.TermID_MIS4 = a.fterm 
				WHERE 
				RIGHT(t.TERMS_ID, 2) NOT IN ('S1','S2','S3') 
		) ft
		ON ft.StudentID = ce.STC_PERSON_ID
		LEFT JOIN 
		datatel.dbo.Cum_GPA_Through_Term_View gpa ON gpa.STUDENT_ID = ce.STC_PERSON_ID AND gpa.TERMS_ID = ce.STC_TERM
		LEFT JOIN 
		datatel.dbo.Person_Ethnicities_View pe ON pe.ID = ce.STC_PERSON_ID
		LEFT JOIN
		datatel.dbo.PERSON_ADDRESSES_VIEW pa ON pa.ID = ce.STC_PERSON_ID 
		LEFT JOIN 
		pro.dbo.CabrilloZips z ON z.ZIP = LEFT(pa.zip,5)
		LEFT JOIN
		(SELECT stc_person_id, sum(stc_cred) AS TotalUnits FROM datatel.dbo.factbook_coreenrollment_view GROUP BY stc_person_id) t ON t.stc_person_id = ce.stc_person_id
		LEFT JOIN 
		(SELECT 
			STC_PERSON_ID 
			FROM 
				[datatel].[dbo].[FACTBOOK_CoreEnrollment_View] 
				WHERE STC_TERM = '2019SP'
		) b ON b.STC_PERSON_ID = ce.STC_PERSON_ID
		LEFT JOIN
		datatel.dbo.STUDENT_RESIDENCY_STATUS_VIEW AS res 
		ON res.STUDENTS_ID = ce.STC_PERSON_ID
		LEFT JOIN
		(SELECT DISTINCT
			ce.[STC_PERSON_ID] AS StudentID,
			COUNT(DISTINCT ce.[STC_TERM]) AS NumPrimaryTerms
			FROM 
				[datatel].[dbo].STUDENT_ACAD_CRED ce
				LEFT JOIN 
				datatel.dbo.terms t
				ON t.TERMS_ID = ce.stc_term
				WHERE 
				t.term_session IN ('FA','SP')
				GROUP BY ce.[STC_PERSON_ID]
		) pt
		ON
		pt.StudentID = ce.STC_PERSON_ID
		LEFT JOIN
		(SELECT DISTINCT
			ce.[STC_PERSON_ID] AS StudentID,
			COUNT(DISTINCT ce.[STC_TERM]) AS NumSecondaryTerms
			FROM 
				[datatel].[dbo].STUDENT_ACAD_CRED ce
				LEFT JOIN 
				datatel.dbo.terms t
				ON t.terms_id = ce.stc_term
				WHERE 
				t.term_session IN ('IN','SU') OR t.term_session IS NULL
				GROUP BY ce.[STC_PERSON_ID]
		) st
		ON st.StudentID = ce.STC_PERSON_ID
		LEFT JOIN
		(SELECT DISTINCT 
			fy.STUDENTS_ID
			FROM 
				datatel.dbo.FosterYouthStatus AS fy
		) AS fy 
		ON fy.STUDENTS_ID = ce.STC_PERSON_ID
		LEFT JOIN
		(SELECT DISTINCT 
			[SA_STUDENT_ID]
			FROM 
				[datatel].[dbo].[FinAidAwards_View]
				WHERE 
				[SA_AWARD] = 'PELL' AND [SA_ACTION] = 'A' OR [SA_XMIT_AMT] > 0
		) AS pell 
		ON ce.STC_PERSON_ID = pell.SA_STUDENT_ID
		LEFT JOIN 
		(SELECT DISTINCT 
			[SA_STUDENT_ID]
			FROM 
				[datatel].[dbo].[FinAidAwards_View]
				WHERE 
				[SA_AWARD] LIKE ('BOG%') AND [SA_ACTION] = 'A' OR [SA_XMIT_AMT] > 0
		) AS bog 
		ON ce.STC_PERSON_ID = bog.SA_STUDENT_ID	
		LEFT JOIN
		(SELECT DISTINCT 
			eops.STUDENT_ID
			FROM 
				[datatel].[dbo].C09_DW_STUDENT_EOPS AS eops
		) AS eops 
		ON ce.STC_PERSON_ID = eops.STUDENT_ID	
		LEFT JOIN
		(SELECT DISTINCT 
			v.ID
			FROM 
				datatel.dbo.VETERAN_ASSOC AS v
				WHERE 
				v.POS = 1 
				AND v.VETERAN_TYPE NOT IN ('S', 'V35', 'VDEP') -- VRAP is iffy, but I left it in
		) AS vet 
		ON ce.STC_PERSON_ID = vet.ID
		LEFT JOIN
		(SELECT DISTINCT 
			eg3.ID AS StudentID, 
			v1.VAL_EXTERNAL_REPRESENTATION, 
			eg3.[PST_EDUC_GOALS] AS EducationGoal,
			CASE WHEN eg3.[PST_EDUC_GOALS] IN ('1','2','1A','1B','1C','1D','1E','1F','1G','2A','2B','2C','2D','2E','2F','2G') THEN 'Transfer' 
				 WHEN eg3.[PST_EDUC_GOALS] = '14'THEN '4yrStudent' ELSE 'Not' END AS TransferEdGoal
			FROM 
				(SELECT 
					eg2.ID, 
					eg2.PST_EDUC_GOALS
					FROM 
						(SELECT
							eg1.ID, 
							eg1.MaxPOS, 
							eg.[PST_EDUC_GOALS]
							FROM 
								(SELECT DISTINCT 
									eg.[PERSON_ST_ID] AS ID, 
									MAX(eg.POS) AS MaxPOS
									FROM 
										[datatel].[dbo].[EDUC_GOALS] AS eg
										GROUP BY eg.[PERSON_ST_ID]
								) AS eg1
								INNER JOIN 
								[datatel].[dbo].[EDUC_GOALS] AS eg
								ON eg1.ID = eg.[PERSON_ST_ID] AND eg1.MaxPOS = eg.[POS]
						) AS eg2
				) AS eg3
				INNER JOIN 
				(SELECT DISTINCT 
					[VALCODE_ID],
					[POS],
					[VAL_MINIMUM_INPUT_STRING],
					[VAL_EXTERNAL_REPRESENTATION]
					FROM 
						[datatel].[dbo].[ST_VALS]
						WHERE 
						valcode_id = 'EDUCATION.GOALS'
				) AS v1
				ON eg3.PST_EDUC_GOALS = v1.[VAL_MINIMUM_INPUT_STRING]
		) eg
		ON eg.StudentID = ce.STC_PERSON_ID
		LEFT JOIN
		(SELECT DISTINCT 
			fg.ID AS StudentID, 
			fg.ParentEdLevel, 
			CASE WHEN fg.ParentEdLevel IN ('11','12','13','14','1X','1Y','21','22','23','24','2X','2Y','31','32','33','34','3X','3Y','41','42','43','44','4X','4Y','X1','X2','X3','X4','Y1','Y2','Y3','Y4') THEN 1 
				 WHEN fg.ParentEdLevel IS NULL OR fg.ParentEdLevel IN ('YY','XX') THEN NULL ELSE 0 END AS FirstGen
			FROM 
				(SELECT 
					[APPLICANTS_ID] AS ID,
					([APP_PARENT1_EDUC_LEVEL] + [APP_PARENT2_EDUC_LEVEL]) AS ParentEdLevel,
					MAX([APPLICANTS_CHGDATE]) AS MaxAppChangeDate
					FROM
						[datatel].[dbo].[APPLICANTS]
						GROUP BY [APPLICANTS_ID], [APP_PARENT1_EDUC_LEVEL], [APP_PARENT2_EDUC_LEVEL]
				) AS fg
		) fg
		ON fg.StudentID = ce.STC_PERSON_ID
		LEFT JOIN
		(SELECT 
			DisPrim.*, 
			DisAll.AllDisabilities
			FROM
				(SELECT DISTINCT 
					d.[PERSON_HEALTH_ID] AS DSPS_ID,
					dd.HC_DESC AS PrimaryDisability
					FROM 
						[datatel].[dbo].[PHL_DISABILITIES] AS d
						INNER JOIN 
						[datatel].[dbo].[DISABILITY] AS dd 
						ON d.[PHL_DISABILITY] = dd.DISABILITY_ID
						WHERE d.PHL_DIS_TYPE = 'PRI'
				) AS DisPrim
				INNER JOIN 
				(SELECT DISTINCT 
					d.[PERSON_HEALTH_ID] AS DSPS_ID,
					datatel.[dbo].[ConcatField](dd.HC_DESC, ', ') AS AllDisabilities
					FROM 
						[datatel].[dbo].[PHL_DISABILITIES] AS d
						INNER JOIN 
						[datatel].[dbo].[DISABILITY] AS dd 
						ON d.[PHL_DISABILITY] = dd.DISABILITY_ID
						GROUP BY [PERSON_HEALTH_ID]
				) AS DisAll
				ON DisPrim.DSPS_ID = DisAll.DSPS_ID
		) ds
		ON ds.DSPS_ID = ce.STC_PERSON_ID