-- Sends the welcome email after each waitlist signup (via the waitlist-welcome Edge Function).
-- Apply only after the Resend domain is verified and RESEND_API_KEY is set.
create or replace function public.waitlist_send_welcome()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform net.http_post(
    url := 'https://jfyqemxtcrffqmbbdbbm.supabase.co/functions/v1/waitlist-welcome',
    body := jsonb_build_object('id', new.id),
    headers := '{"Content-Type":"application/json"}'::jsonb
  );
  return new;
end;
$$;

revoke all on function public.waitlist_send_welcome() from public, anon, authenticated;

drop trigger if exists waitlist_send_welcome on public.waitlist;
create trigger waitlist_send_welcome
after insert on public.waitlist
for each row execute function public.waitlist_send_welcome();
