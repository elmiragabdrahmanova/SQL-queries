SELECT 
  client_id, 
  created_at, 
  action_type 
FROM 
  (
    SELECT 
      client_id, 
      created_at, 
      action_type, 
      CASE WHEN EXTRACT (
        EPOCH 
        FROM 
          (
            created_at - LAG(created_at) OVER (
              PARTITION BY client_id 
              ORDER BY 
                created_at
            )
          )
      ) < 10 
      AND action_type != LAG(action_type) OVER (
        PARTITION BY client_id 
        ORDER BY 
          created_at
      ) 
      OR EXTRACT (
        EPOCH 
        FROM 
          (
            LEAD(created_at) OVER (
              PARTITION BY client_id 
              ORDER BY 
                created_at
            ) - created_at
          )
      ) < 10 
      AND action_type != LEAD(action_type) OVER (
        PARTITION BY client_id 
        ORDER BY 
          created_at
      ) THEN 1 ELSE 0 END AS criteria 
    FROM 
      yourtable
  ) AS resulttable 
WHERE 
  criteria = 1 
ORDER BY 
  client_id, 
  created_at;
