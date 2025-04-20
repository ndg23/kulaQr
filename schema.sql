-- Marketing Campaigns Table
CREATE TABLE marketing_campaigns (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(50) NOT NULL, -- 'PROMO', 'EVENT', 'LOYALTY'
  description TEXT,
  start_date TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,
  status VARCHAR(50) DEFAULT 'DRAFT', -- 'DRAFT', 'ACTIVE', 'PAUSED', 'ENDED'
  conditions JSONB, -- Conditions spécifiques (ex: réduction, points requis)
  target_audience JSONB, -- Critères de ciblage
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Marketing Metrics Table
CREATE TABLE marketing_metrics (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  campaign_id UUID REFERENCES marketing_campaigns(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  impressions INTEGER DEFAULT 0,
  clicks INTEGER DEFAULT 0,
  conversions INTEGER DEFAULT 0,
  revenue DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Customer Loyalty Table
CREATE TABLE customer_loyalty (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  customer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
  points INTEGER DEFAULT 0,
  tier VARCHAR(50) DEFAULT 'BRONZE', -- 'BRONZE', 'SILVER', 'GOLD'
  last_visit TIMESTAMP WITH TIME ZONE,
  total_visits INTEGER DEFAULT 0,
  total_spent DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(customer_id, establishment_id)
);

-- Promotional Codes Table
CREATE TABLE promo_codes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  campaign_id UUID REFERENCES marketing_campaigns(id) ON DELETE CASCADE,
  code VARCHAR(50) UNIQUE NOT NULL,
  discount_type VARCHAR(20) NOT NULL, -- 'PERCENTAGE', 'FIXED'
  discount_value DECIMAL(10,2) NOT NULL,
  min_purchase DECIMAL(10,2) DEFAULT 0,
  max_uses INTEGER,
  uses_count INTEGER DEFAULT 0,
  start_date TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE marketing_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE marketing_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_loyalty ENABLE ROW LEVEL SECURITY;
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

-- Policies for marketing_campaigns
CREATE POLICY "Establishments can manage their campaigns"
  ON marketing_campaigns
  FOR ALL
  USING (establishment_id IN (
    SELECT id FROM establishments 
    WHERE owner_id = auth.uid()
  ));

-- Policies for marketing_metrics
CREATE POLICY "Establishments can view their campaign metrics"
  ON marketing_metrics
  FOR ALL
  USING (campaign_id IN (
    SELECT id FROM marketing_campaigns 
    WHERE establishment_id IN (
      SELECT id FROM establishments 
      WHERE owner_id = auth.uid()
    )
  ));

-- Policies for customer_loyalty
CREATE POLICY "Customers can view their own loyalty data"
  ON customer_loyalty
  FOR SELECT
  USING (customer_id = auth.uid());

CREATE POLICY "Establishments can manage loyalty data"
  ON customer_loyalty
  FOR ALL
  USING (establishment_id IN (
    SELECT id FROM establishments 
    WHERE owner_id = auth.uid()
  ));

-- Policies for promo_codes
CREATE POLICY "Establishments can manage their promo codes"
  ON promo_codes
  FOR ALL
  USING (campaign_id IN (
    SELECT id FROM marketing_campaigns 
    WHERE establishment_id IN (
      SELECT id FROM establishments 
      WHERE owner_id = auth.uid()
    )
  )); 