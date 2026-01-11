-- RPC function to get total revenue by statuses
CREATE OR REPLACE FUNCTION get_total_revenue_by_statuses(p_statuses TEXT[])
RETURNS NUMERIC AS $$
DECLARE
  v_total NUMERIC;
BEGIN
  SELECT COALESCE(SUM(total_amount), 0)
  INTO v_total
  FROM reservations
  WHERE status = ANY(p_statuses);

  RETURN v_total;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_total_revenue_by_statuses(TEXT[]) TO authenticated;
GRANT EXECUTE ON FUNCTION get_total_revenue_by_statuses(TEXT[]) TO anon;
