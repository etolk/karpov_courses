SELECT
	client_id,
	purchase_date,
	client_city,
	city,
	client_age,
	client_registration_age,
	if(count(purchase_id) > 1, 'old', 'new') as client_category -- если у одного клиента больше 1 покупки, то old
	promotion_name,
	category_name,
	partner_name,
	quantity,
	revenue
FROM
	(
	SELECT
		purchase_date,
		purchase_id,
		client_id,
		client_city,
		city,
		client_age,
		client_registration_age,
		promotion_name,
		category_name,
		partner_name,
		quantity,
		quantity * price as revenue
	FROM purchase

	LEFT JOIN

			(
			SELECT
				client_id as client_id_join,
				client_city,
				client_age,
				client_registration_age
			FROM
				(
				SELECT
					client_id,
					client_city_id,
					client_city,
					toYear(now()) - toYear(birth_date) as client_age, -- считаем возраст как разница между сегодняшним годом и годом рождения
					toDate(now()) - toDate(registration) as client_registration_age -- считаем как долго человек пользуется вашими магазинами как разница в днях между сегодняшней датой и датой регистрации
				FROM client

				INNER JOIN

						(
						SELECT
							client_city_id as client_city_id_join,
							client_city
						FROM city
						GROUP BY
							client_city_id,
							client_city

						) ON client_city_id = client_city_id_join

				GROUP BY
					client_id,
					client_city_id,
					birth_date,
					registration,
					client_city
				)
			GROUP BY
				client_id_join,
				client_city,
				client_age,
				client_registration_age

			) ON client_id = client_id_join

	LEFT JOIN
			
			(
			SELECT
				promotion_id as promotion_id_join,
				category_id as category_id_join,
				partner_id as partner_id_join,
				promotion_name,
				category_name,
				partner_name
			FROM promotion
			GROUP BY
				promotion_id_join,
				category_id_join,
				partner_id_join,
				promotion_name,
				category_name,
				partner_name

				) ON promotion_id = promotion_id_join and category_id = category_id_join and partner_id = partner_id_join

	LEFT JOIN

			(
			SELECT
				city_id as city_id_join,
				city,
			FROM city
			GROUP BY
				city_id_join,
				city

				) ON client_id = client_id_join

	WHERE
		toDate(purchase_date) >= '2020-05-01' AND toDate(purchase_date) <= '2020-08-01'
		AND status = 1
	GROUP BY
		client_id,
		purchase_date,
		purchase_id,
		client_city,
		client_age,
		client_registration_age,
		promotion_name,
		category_name,
		partner_name,
		city,
		quantity,
		price
	)
GROUP BY
	client_id,
	purchase_date,
	client_city,
	city,
	client_age,
	client_registration_age,
	promotion_name,
	category_name,
	partner_name,
	quantity,
	revenue