--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2 (Debian 15.2-1.pgdg110+1)
-- Dumped by pg_dump version 15.4 (Ubuntu 15.4-2.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: cube; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;


--
-- Name: EXTENSION cube; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION cube IS 'data type for multidimensional cubes';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: isn; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS isn WITH SCHEMA public;


--
-- Name: EXTENSION isn; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION isn IS 'data types for international product numbering standards';


--
-- Name: lo; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS lo WITH SCHEMA public;


--
-- Name: EXTENSION lo; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION lo IS 'Large Object maintenance';


--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


--
-- Name: pg_buffercache; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_buffercache WITH SCHEMA public;


--
-- Name: EXTENSION pg_buffercache; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_buffercache IS 'examine the shared buffer cache';


--
-- Name: pg_prewarm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_prewarm WITH SCHEMA public;


--
-- Name: EXTENSION pg_prewarm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_prewarm IS 'prewarm relation data';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgrowlocks; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgrowlocks WITH SCHEMA public;


--
-- Name: EXTENSION pgrowlocks; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgrowlocks IS 'show row-level locking information';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id uuid NOT NULL,
    email_address public.citext NOT NULL,
    confirmed_at timestamp(0) without time zone,
    username public.citext,
    onboarding_state public.citext NOT NULL,
    hashed_password character varying(255) NOT NULL,
    profile jsonb DEFAULT '{}'::jsonb NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    provider text,
    provider_access_token text,
    provider_refresh_token text,
    provider_token_expiration integer,
    provider_id text,
    avatar_uri text,
    provider_scopes text[] DEFAULT ARRAY[]::text[]
);


--
-- Name: accounts_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts_tokens (
    id uuid NOT NULL,
    account_id uuid NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: backgrounds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.backgrounds (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL
);


--
-- Name: characters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.characters (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    hitpoints integer DEFAULT 0 NOT NULL,
    strength integer DEFAULT 8 NOT NULL,
    dexterity integer DEFAULT 8 NOT NULL,
    constitution integer DEFAULT 8 NOT NULL,
    intelligence integer DEFAULT 8 NOT NULL,
    wisdom integer DEFAULT 8 NOT NULL,
    charisma integer DEFAULT 8 NOT NULL,
    inspiration integer DEFAULT 0 NOT NULL,
    lineage_choices jsonb DEFAULT '{}'::jsonb NOT NULL,
    background_choices jsonb DEFAULT '{}'::jsonb NOT NULL,
    pronouns jsonb NOT NULL,
    account_id uuid NOT NULL,
    lineage_id uuid NOT NULL,
    background_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: classes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.classes (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    levels jsonb NOT NULL,
    saving_throw_proficiencies text[] NOT NULL,
    hit_dice integer NOT NULL
);


--
-- Name: dialogues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dialogues (
    id uuid NOT NULL,
    speaker_id uuid,
    body text NOT NULL
);


--
-- Name: inventories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventories (
    id uuid NOT NULL,
    character_id uuid NOT NULL,
    item_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL
);


--
-- Name: levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.levels (
    id uuid NOT NULL,
    "position" integer NOT NULL,
    class_id uuid NOT NULL,
    character_id uuid NOT NULL,
    choices jsonb NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: lineage_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lineage_categories (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL
);


--
-- Name: lineages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lineages (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    lineage_category_id uuid
);


--
-- Name: participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.participants (
    id uuid NOT NULL,
    character_id uuid NOT NULL,
    scene_id uuid NOT NULL
);


--
-- Name: scenes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scenes (
    id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id uuid NOT NULL,
    name text NOT NULL,
    slug public.citext NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: accounts_tokens accounts_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_tokens
    ADD CONSTRAINT accounts_tokens_pkey PRIMARY KEY (id);


--
-- Name: backgrounds backgrounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backgrounds
    ADD CONSTRAINT backgrounds_pkey PRIMARY KEY (id);


--
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- Name: dialogues dialogues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dialogues
    ADD CONSTRAINT dialogues_pkey PRIMARY KEY (id);


--
-- Name: inventories inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (id);


--
-- Name: lineage_categories lineage_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lineage_categories
    ADD CONSTRAINT lineage_categories_pkey PRIMARY KEY (id);


--
-- Name: lineages lineages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lineages
    ADD CONSTRAINT lineages_pkey PRIMARY KEY (id);


--
-- Name: participants participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_pkey PRIMARY KEY (id);


--
-- Name: scenes scenes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scenes
    ADD CONSTRAINT scenes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: accounts_email_address_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX accounts_email_address_index ON public.accounts USING btree (email_address);


--
-- Name: accounts_onboarding_state_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_onboarding_state_index ON public.accounts USING btree (onboarding_state);


--
-- Name: accounts_tokens_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accounts_tokens_account_id_index ON public.accounts_tokens USING btree (account_id);


--
-- Name: accounts_tokens_context_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX accounts_tokens_context_token_index ON public.accounts_tokens USING btree (context, token);


--
-- Name: backgrounds_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX backgrounds_slug_index ON public.backgrounds USING btree (slug);


--
-- Name: characters_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX characters_account_id_index ON public.characters USING btree (account_id);


--
-- Name: characters_background_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX characters_background_id_index ON public.characters USING btree (background_id);


--
-- Name: characters_lineage_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX characters_lineage_id_index ON public.characters USING btree (lineage_id);


--
-- Name: characters_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX characters_slug_index ON public.characters USING btree (slug);


--
-- Name: classes_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX classes_slug_index ON public.classes USING btree (slug);


--
-- Name: dialogues_speaker_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dialogues_speaker_id_index ON public.dialogues USING btree (speaker_id);


--
-- Name: inventories_character_id_item_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventories_character_id_item_id_index ON public.inventories USING btree (character_id, item_id);


--
-- Name: inventories_item_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inventories_item_id_index ON public.inventories USING btree (item_id);


--
-- Name: items_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX items_slug_index ON public.items USING btree (slug);


--
-- Name: levels_character_id_class_id_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX levels_character_id_class_id_position_index ON public.levels USING btree (character_id, class_id, "position");


--
-- Name: levels_class_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX levels_class_id_index ON public.levels USING btree (class_id);


--
-- Name: levels_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX levels_position_index ON public.levels USING btree ("position");


--
-- Name: lineage_categories_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lineage_categories_slug_index ON public.lineage_categories USING btree (slug);


--
-- Name: lineages_lineage_category_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lineages_lineage_category_id_index ON public.lineages USING btree (lineage_category_id);


--
-- Name: lineages_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lineages_slug_index ON public.lineages USING btree (slug);


--
-- Name: participants_character_id_scene_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX participants_character_id_scene_id_index ON public.participants USING btree (character_id, scene_id);


--
-- Name: participants_scene_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX participants_scene_id_index ON public.participants USING btree (scene_id);


--
-- Name: tags_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX tags_slug_index ON public.tags USING btree (slug);


--
-- Name: accounts_tokens accounts_tokens_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_tokens
    ADD CONSTRAINT accounts_tokens_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: characters characters_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: characters characters_background_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_background_id_fkey FOREIGN KEY (background_id) REFERENCES public.backgrounds(id) ON DELETE CASCADE;


--
-- Name: characters characters_lineage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_lineage_id_fkey FOREIGN KEY (lineage_id) REFERENCES public.lineages(id) ON DELETE CASCADE;


--
-- Name: dialogues dialogues_speaker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dialogues
    ADD CONSTRAINT dialogues_speaker_id_fkey FOREIGN KEY (speaker_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- Name: inventories inventories_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- Name: inventories inventories_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: levels levels_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- Name: levels levels_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE CASCADE;


--
-- Name: lineages lineages_lineage_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lineages
    ADD CONSTRAINT lineages_lineage_category_id_fkey FOREIGN KEY (lineage_category_id) REFERENCES public.lineage_categories(id) ON DELETE CASCADE;


--
-- Name: participants participants_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- Name: participants participants_scene_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_scene_id_fkey FOREIGN KEY (scene_id) REFERENCES public.scenes(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20191225213553);
INSERT INTO public."schema_migrations" (version) VALUES (20191225213554);
INSERT INTO public."schema_migrations" (version) VALUES (20201215210357);
INSERT INTO public."schema_migrations" (version) VALUES (20220209090825);
INSERT INTO public."schema_migrations" (version) VALUES (20221230230314);
INSERT INTO public."schema_migrations" (version) VALUES (20231001233442);
INSERT INTO public."schema_migrations" (version) VALUES (20231001235545);
INSERT INTO public."schema_migrations" (version) VALUES (20231001235546);
INSERT INTO public."schema_migrations" (version) VALUES (20231001235547);
INSERT INTO public."schema_migrations" (version) VALUES (20231001235550);
INSERT INTO public."schema_migrations" (version) VALUES (20231001235551);
INSERT INTO public."schema_migrations" (version) VALUES (20231002000051);
INSERT INTO public."schema_migrations" (version) VALUES (20231002020243);
INSERT INTO public."schema_migrations" (version) VALUES (20231002023304);
INSERT INTO public."schema_migrations" (version) VALUES (20231002023305);
INSERT INTO public."schema_migrations" (version) VALUES (20231028201929);
