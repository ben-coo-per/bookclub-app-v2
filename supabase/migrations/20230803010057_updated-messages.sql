alter table "public"."message" drop constraint "message_author_fkey";

alter table "public"."message" drop constraint "message_pkey";

drop index if exists "public"."message_pkey";

drop table "public"."message";

create table "public"."messages" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone default now(),
    "author" uuid not null,
    "text" text
);


alter table "public"."messages" enable row level security;

CREATE UNIQUE INDEX message_pkey ON public.messages USING btree (id);

alter table "public"."messages" add constraint "message_pkey" PRIMARY KEY using index "message_pkey";

alter table "public"."messages" add constraint "messages_author_fkey" FOREIGN KEY (author) REFERENCES user_profiles(id) not valid;

alter table "public"."messages" validate constraint "messages_author_fkey";

create policy "Enable delete for users based on user_id"
on "public"."messages"
as permissive
for delete
to public
using ((auth.uid() = author));


create policy "Enable insert for authenticated users only"
on "public"."messages"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."messages"
as permissive
for select
to public
using (true);


create policy "Enable update for users based on user_id"
on "public"."messages"
as permissive
for update
to public
using ((auth.uid() = author))
with check ((auth.uid() = author));


