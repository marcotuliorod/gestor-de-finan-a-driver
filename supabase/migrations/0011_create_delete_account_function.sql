CREATE OR REPLACE FUNCTION delete_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  DELETE FROM maintenance_records WHERE user_id = uid;
  DELETE FROM mileage_records     WHERE user_id = uid;
  DELETE FROM fuel_records        WHERE user_id IN (
    SELECT id FROM expenses WHERE user_id = uid
  );
  DELETE FROM expenses            WHERE user_id = uid;
  DELETE FROM trips               WHERE user_id = uid;
  DELETE FROM goals               WHERE user_id = uid;
  DELETE FROM platforms           WHERE user_id = uid;
  DELETE FROM vehicles            WHERE user_id = uid;
  DELETE FROM ai_conversations    WHERE user_id = uid;

  DELETE FROM auth.users WHERE id = uid;
END;
$$;

GRANT EXECUTE ON FUNCTION delete_account() TO authenticated;
