-- Average order value by browser
SELECT browser,
    AVG(brw_avg_order) AS avg_order
FROM (
        WITH brw_usr AS (
            SELECT user_id,
                browser,
                COUNT(1) AS brw_count
            FROM `ecommerce_post.events`
            WHERE user_id IS NOT NULL
            GROUP BY user_id,
                browser
        )
        SELECT b_u.user_id,
            b_u.browser,
            (b_u.brw_count / b_t.total_count) * avg_ord.avg_order AS brw_avg_order
        FROM brw_usr AS b_u
            JOIN (
                SELECT user_id,
                    SUM(brw_count) AS total_count
                FROM brw_usr
                GROUP BY user_id
            ) AS b_t ON b_u.user_id = b_t.user_id
            JOIN (
                SELECT user_id,
                    AVG(total_sum) AS avg_order
                FROM (
                        SELECT order_id,
                            user_id,
                            SUM(sale_price) AS total_sum
                        FROM `ecommerce_post.order_items`
                        GROUP BY order_id,
                            user_id
                    ) AS usr_avg_order
                GROUP BY user_id
            ) AS avg_ord ON avg_ord.user_id = b_u.user_id
    ) AS avg_usr_brw_ord
GROUP BY browser;
-- Most-ordered products:
SELECT prd.name,
    cnt_prd.prd_id,
    cnt_prd.country
FROM (
        SELECT country,
            COUNT(1) AS orders_count
        FROM `ecommerce_post.users` AS usr
            JOIN `ecommerce_post.orders` AS ord ON usr.id = ord.user_id
        GROUP BY country
        ORDER BY orders_count DESC
        LIMIT 10
    ) AS top_cnt
    JOIN (
        SELECT DISTINCT country,
            FIRST_VALUE(product_id) OVER(
                PARTITION BY country
                ORDER BY prd_count DESC
            ) AS prd_id
        FROM (
                SELECT ord_it.product_id,
                    usr.country,
                    COUNT(1) AS prd_count
                FROM `ecommerce_post.users` AS usr
                    JOIN `ecommerce_post.order_items` AS ord_it ON usr.id = ord_it.user_id
                GROUP BY ord_it.product_id,
                    usr.country
            )
    ) AS cnt_prd ON cnt_prd.country = top_cnt.country
    JOIN `ecommerce_post.products` AS prd ON cnt_prd.prd_id = prd.id -- Delivery times:
SELECT country,
    AVG(DATE_DIFF(delivered_at, shipped_at, DAY)) AS days_diff,
    COUNT(1) AS orders_count
FROM `ecommerce_post.users` AS usr
    JOIN `ecommerce_post.orders` AS ord ON usr.id = ord.user_id
GROUP BY country
ORDER BY orders_count DESC
LIMIT 10;
-- Delivery times:
SELECT country,
    AVG(DATE_DIFF(delivered_at, shipped_at, DAY)) AS days_diff,
    COUNT(1) AS orders_count
FROM `ecommerce_post.users` AS usr
    JOIN `ecommerce_post.orders` AS ord ON usr.id = ord.user_id
GROUP BY country
ORDER BY orders_count DESC
LIMIT 10;
-- Merging Tables:
SELECT *
FROM `ecommerce_post.events` AS evn
    JOIN `ecommerce_post.users` AS usr ON usr.id = evn.user_id
    JOIN `ecommerce_post.orders` AS ord ON ord.user_id = usr.id
    AND (DATE(evn.created_at) = DATE(ord.created_at))
    JOIN `ecommerce_post.order_items` AS ord_it ON ord_it.order_id = ord.order_id