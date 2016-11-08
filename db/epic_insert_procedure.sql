DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_insert_epic_prescriptions`$$

CREATE PROCEDURE `proc_insert_epic_prescriptions`(
	IN provider_fname VARCHAR(255), 
	IN provider_lname VARCHAR(255),
	IN patient_fname VARCHAR(255),
	IN patient_lname VARCHAR(255),
	IN patient_epic_id VARCHAR(255),
	IN patient_gender VARCHAR(255),
	IN patient_birthdate VARCHAR(255),
	IN patient_address VARCHAR(255),
	IN patient_city VARCHAR(255),
	IN patient_state VARCHAR(255),
	IN patient_zip VARCHAR(255),
	IN patient_phone VARCHAR(255),
	IN rx_date_prescribed VARCHAR(255),
	IN rx_quantity INT,
	IN rx_directions VARCHAR(255),
	IN ndc_code VARCHAR(255),
	IN drug_name VARCHAR(255)
)
BEGIN

  START TRANSACTION;	
	UPDATE patients SET first_name = patient_fname, last_name = patient_lname, gender = patient_gender, birthdate = STR_TO_DATE(patient_birthdate, '%Y%m%d'), address = patient_address, city = patient_city, state = patient_state, zip = patient_state, phone = patient_phone, voided= false,updated_at = now() WHERE epic_id= patient_epic_id;
	
	IF (ROW_COUNT() = 0) THEN		
	    INSERT INTO patients (epic_id, first_name, last_name, gender, birthdate, address, city, state, zip, phone, voided, created_at, updated_at) VALUES (patient_epic_id, patient_fname, patient_lname, patient_gender, STR_TO_DATE(patient_birthdate, '%Y%m%d'), patient_address, patient_city, patient_state, patient_zip, patient_phone, FALSE, now(), now());
	END IF;

	UPDATE providers SET first_name = provider_fname , last_name = provider_lname, updated_at = now()  WHERE first_name = provider_fname AND last_name = provider_lname;

	IF (ROW_COUNT() = 0) THEN
		INSERT INTO providers ( first_name, last_name, created_at, updated_at) VALUES (provider_fname ,provider_lname, now(),now());

	END IF;

	SET @drug_id = (SELECT RXAUI FROM  RXNSAT  WHERE ATV = ndc_code LIMIT 1);
	SET @drug_name = (SELECT STR FROM RXNCONSO WHERE RXAUI = @drug_id LIMIT 1);
	SET @patient_id = (SELECT patient_id FROM patients WHERE epic_id= patient_epic_id LIMIT 1);
	SET @provider_id = (SELECT provider_id FROM providers WHERE first_name = provider_fname AND last_name = provider_lname LIMIT 1);

  IF (@drug_id IS NULL) THEN

      SET @drug_id = (SELECT rxaui FROM ndc_code_matches WHERE missing_code = ndc_code LIMIT 1);

      IF (@drug_id IS NULL) THEN
        INSERT INTO hl7_errors (patient_id, date_prescribed, drug_name,quantity, directions, provider_id,code, voided, created_at, updated_at) VALUES ( @patient_id, COALESCE(STR_TO_DATE(rx_date_prescribed, '%Y%m%d %h%i%s'), now()),drug_name, COALESCE(rx_quantity,0), rx_directions, @provider_id,ndc_code, FALSE, now(), now());
        SET @msg = CONCAT("Missing NDC code for ", drug_name);
        INSERT INTO news (message, refers_to, news_type, created_at, updated_at) VALUES (@msg,ndc_code,"Missing Reference",now(),now());
      ELSE
        UPDATE prescriptions SET patient_id = @patient_id, rxaui = @drug_id, date_prescribed = COALESCE(STR_TO_DATE(rx_date_prescribed, '%Y%m%d %h%i%s'), now()), quantity = COALESCE(rx_quantity,0), directions = rx_directions, provider_id = @provider_id, voided = FALSE, updated_at = now() WHERE rxaui = @drug_id AND patient_id = @patient_id AND DATE(date_prescribed) = COALESCE(STR_TO_DATE(rx_date_prescribed, '%Y%m%d'), DATE(now()));

        IF (ROW_COUNT() = 0) THEN
          INSERT INTO prescriptions (patient_id, rxaui,date_prescribed, quantity, directions, provider_id, voided, created_at, updated_at) VALUES ( @patient_id,@drug_id, COALESCE(STR_TO_DATE(rx_date_prescribed, '%Y%m%d %h%i%s'), now()), COALESCE(rx_quantity,0), rx_directions, @provider_id, FALSE, now(), now());
        END IF;
      END IF;
      COMMIT;
  ELSE
	  UPDATE prescriptions SET patient_id = @patient_id, rxaui = @drug_id, date_prescribed = COALESCE(STR_TO_DATE(rx_date_prescribed, '%Y%m%d %h%i%s'), now()), quantity = COALESCE(rx_quantity,0), directions = rx_directions, provider_id = @provider_id, voided = FALSE, updated_at = now() WHERE rxaui = @drug_id AND patient_id = @patient_id AND DATE(date_prescribed) = COALESCE(STR_TO_DATE(rx_date_prescribed, '%Y%m%d'), DATE(now()));
	
    IF (ROW_COUNT() = 0) THEN
		  INSERT INTO prescriptions (patient_id, rxaui,date_prescribed, quantity, directions, provider_id, voided, created_at, updated_at) VALUES ( @patient_id,@drug_id, COALESCE(STR_TO_DATE(rx_date_prescribed, '%Y%m%d %h%i%s'), now()), COALESCE(rx_quantity,0), rx_directions, @provider_id, FALSE, now(), now());

      /*SET @prescription_id = (SELECT rx_id FROM prescriptions WHERE patient_id = @patient_id AND rxaui = @drug_id AND DATE(date_prescribed) = COALESCE(STR_TO_DATE(rx_date_prescribed, '%Y%m%d'), DATE(now())) ORDER BY date_prescribed DESC LIMIT 1);
      
      SET @msg = CONCAT(rx_quantity, " of ", @drug_name, " for ",  patient_fname," ", patient_lname);

      INSERT INTO news (message, refers_to, news_type, created_at, updated_at) VALUES (@msg,@prescription_id,"new prescription",now(),now());
      */
	  END IF;
    COMMIT;
  END IF;

END$$


DELIMITER ;
