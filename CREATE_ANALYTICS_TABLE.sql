-- Create analytics_events table for tracking admin dashboard analytics
-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS analytics_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_type VARCHAR(100) NOT NULL,
  page_name VARCHAR(200),
  page_title VARCHAR(200),
  entity_id VARCHAR(100),
  entity_name VARCHAR(200),
  user_id VARCHAR(100),
  parameters JSONB DEFAULT '{}',
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  user_agent VARCHAR(200),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_analytics_events_event_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_events_timestamp ON analytics_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_entity_id ON analytics_events(entity_id);

-- Create a view for daily analytics summary
CREATE OR REPLACE VIEW daily_analytics_summary AS
SELECT 
  DATE(timestamp) as date,
  event_type,
  COUNT(*) as event_count,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(DISTINCT entity_id) as unique_entities
FROM analytics_events
GROUP BY DATE(timestamp), event_type
ORDER BY date DESC, event_count DESC;

-- Create a view for admin activity summary
CREATE OR REPLACE VIEW admin_activity_summary AS
SELECT 
  DATE(timestamp) as date,
  user_id,
  COUNT(*) as total_actions,
  COUNT(CASE WHEN event_type LIKE 'admin_%' THEN 1 END) as admin_actions,
  COUNT(CASE WHEN event_type = 'page_view' THEN 1 END) as page_views,
  COUNT(CASE WHEN event_type = 'admin_product_action' THEN 1 END) as product_actions,
  COUNT(CASE WHEN event_type = 'admin_order_action' THEN 1 END) as order_actions,
  COUNT(CASE WHEN event_type = 'admin_category_action' THEN 1 END) as category_actions
FROM analytics_events
WHERE user_id IS NOT NULL
GROUP BY DATE(timestamp), user_id
ORDER BY date DESC, total_actions DESC;

-- Enable Row Level Security (RLS)
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (adjust as needed for your security requirements)
CREATE POLICY "Allow all operations on analytics_events" ON analytics_events
FOR ALL USING (true);

-- Create policy for the views
CREATE POLICY "Allow all operations on daily_analytics_summary" ON daily_analytics_summary
FOR ALL USING (true);

CREATE POLICY "Allow all operations on admin_activity_summary" ON admin_activity_summary
FOR ALL USING (true);

-- Insert sample data (optional)
INSERT INTO analytics_events (event_type, page_name, page_title, parameters, user_agent) VALUES
('page_view', 'dashboard', 'Admin Dashboard', '{"section": "overview"}', 'admin_dashboard'),
('admin_product_action', 'products', 'Products Management', '{"action": "view", "product_count": 12}', 'admin_dashboard'),
('admin_order_action', 'orders', 'Orders Management', '{"action": "view", "order_count": 4}', 'admin_dashboard');

COMMENT ON TABLE analytics_events IS 'Stores analytics events from the admin dashboard';
COMMENT ON COLUMN analytics_events.event_type IS 'Type of event (page_view, admin_product_action, etc.)';
COMMENT ON COLUMN analytics_events.parameters IS 'Additional event parameters as JSON';
COMMENT ON COLUMN analytics_events.entity_id IS 'ID of the entity being acted upon (product_id, order_id, etc.)';
COMMENT ON COLUMN analytics_events.entity_name IS 'Name of the entity being acted upon';
