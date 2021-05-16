BEGIN;

-- Table: public.car

-- DROP TABLE public.car;

CREATE TABLE public.car
(
    car_id integer NOT NULL,
    manufacturer character varying(255) COLLATE pg_catalog."default" NOT NULL,
    model_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    serial_number character varying(255) COLLATE pg_catalog."default" NOT NULL,
    weight double precision,
    price double precision NOT NULL,
    CONSTRAINT car_pkey PRIMARY KEY (car_id)
)

TABLESPACE pg_default;

ALTER TABLE public.car
    OWNER to postgres;

    -- Table: public.customer

    -- DROP TABLE public.customer;

    CREATE TABLE public.customer
    (
        customer_id integer NOT NULL,
        customer_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
        customer_phone character varying(50) COLLATE pg_catalog."default" NOT NULL,
        customer_address character varying(255) COLLATE pg_catalog."default",
        CONSTRAINT customer_pkey PRIMARY KEY (customer_id)
    )

    TABLESPACE pg_default;

    ALTER TABLE public.customer
        OWNER to postgres;


        -- Table: public.salesperson

        -- DROP TABLE public.salesperson;

        CREATE TABLE public.salesperson
        (
            salesperson_id integer NOT NULL,
            salesperson_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
            salesperson_phone character varying(50) COLLATE pg_catalog."default" NOT NULL,
            salesperson_email character varying(255) COLLATE pg_catalog."default",
            CONSTRAINT salesperson_pkey PRIMARY KEY (salesperson_id)
        )

        TABLESPACE pg_default;

        ALTER TABLE public.salesperson
            OWNER to postgres;


    -- Table: public.sales_txn

    -- DROP TABLE public.sales_txn;

    CREATE TABLE public.sales_txn
    (
        txn_id bigint NOT NULL,
        txn_date timestamp without time zone NOT NULL,
        customer_id integer NOT NULL,
        salesperson_id integer NOT NULL,
        car_id integer NOT NULL,
        quantity smallint NOT NULL,
        total_amount double precision NOT NULL,
        remarks character varying COLLATE pg_catalog."default",
        CONSTRAINT sales_txn_pkey PRIMARY KEY (txn_id),
        CONSTRAINT car_fk FOREIGN KEY (txn_id)
            REFERENCES public.car (car_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
        CONSTRAINT customer_fk FOREIGN KEY (customer_id)
            REFERENCES public.customer (customer_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
        CONSTRAINT salesperson_fk FOREIGN KEY (salesperson_id)
            REFERENCES public.salesperson (salesperson_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE RESTRICT
    )

    TABLESPACE pg_default;

    ALTER TABLE public.sales_txn
        OWNER to postgres;

-- View: public.vw_cust_ttl_spend

-- DROP VIEW public.vw_cust_ttl_spend;

CREATE OR REPLACE VIEW public.vw_cust_ttl_spend
 AS
 SELECT cs.customer_name,
    sum(txn.total_amount) AS total_spending
   FROM sales_txn txn
     JOIN customer cs ON txn.customer_id = cs.customer_id
  GROUP BY cs.customer_name;

ALTER TABLE public.vw_cust_ttl_spend
    OWNER TO postgres;


-- View: public.vw_top3_manufacturers_curr_mth

-- DROP VIEW public.vw_top3_manufacturers_curr_mth;

CREATE OR REPLACE VIEW public.vw_top3_manufacturers_curr_mth
 AS
 SELECT rk.manufacturer,
    rk.sales_quantity,
    rk.sales_number,
    rk.ranking
   FROM ( SELECT a.manufacturer,
            a.sales_quantity,
            a.sales_number,
            rank() OVER (ORDER BY a.sales_quantity DESC, a.sales_number DESC) AS ranking
           FROM ( SELECT car.manufacturer,
                    sum(txn.quantity) AS sales_quantity,
                    sum(txn.total_amount) AS sales_number
                   FROM sales_txn txn
                     JOIN car car ON txn.car_id = car.car_id
                  WHERE date_trunc('month'::text, txn.txn_date) = date_trunc('month'::text, CURRENT_DATE::timestamp with time zone)
                  GROUP BY car.manufacturer) a) rk
  WHERE rk.ranking <= 3
  ORDER BY rk.ranking;

ALTER TABLE public.vw_top3_manufacturers_curr_mth
    OWNER TO postgres;


COMMIT;
