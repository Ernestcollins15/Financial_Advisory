-- Adding today's date column
ALTER TABLE public."One_Acre_Fund_Data" ADD COLUMN today DATE;

-- Updating the today column with the current date
UPDATE public."One_Acre_Fund_Data" SET today = CURRENT_DATE;

-- Adding the days_past_due column
ALTER TABLE public."One_Acre_Fund_Data" ADD COLUMN days_past_due INTEGER;

-- Calculating the difference between today's date and next_contract_payment_due_date
UPDATE public."One_Acre_Fund_Data" 
SET days_past_due = EXTRACT(DAY FROM (today - next_contract_payment_due_date));

-- Defining the assign_par_status function
CREATE OR REPLACE FUNCTION public.assign_par_status(days_past_due INTEGER) RETURNS TEXT AS $$
BEGIN
    IF days_past_due > 90 THEN
        RETURN 'PAR90+';
    ELSIF days_past_due > 30 THEN
        RETURN 'PAR31-90';
    ELSIF days_past_due > 7 THEN
        RETURN 'PAR8-30';
    ELSIF days_past_due >= 0 THEN
        RETURN 'PAR0-7';
    ELSE
        RETURN 'On Time';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Adding the PAR_status column
ALTER TABLE public."One_Acre_Fund_Data" ADD COLUMN PAR_status TEXT;

-- Updating PAR_status using the assign_par_status function
UPDATE public."One_Acre_Fund_Data" 
SET PAR_status = public.assign_par_status(days_past_due);

-- Checking if the query works
SELECT 
	* 
FROM public."One_Acre_Fund_Data"
LIMIT 100

