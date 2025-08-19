-- Create subscriptions table for managing user subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    product_id VARCHAR(100) NOT NULL,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('android', 'ios')),
    order_id VARCHAR(255) NOT NULL,
    purchase_token TEXT,
    expiry_date TIMESTAMP NOT NULL,
    auto_renewing BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure one active subscription per user per platform
    UNIQUE(user_id, platform)
);

-- Create indexes for better query performance
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_expiry_date ON subscriptions(expiry_date);
CREATE INDEX idx_subscriptions_product_id ON subscriptions(product_id);

-- Create subscription history table for audit trail
CREATE TABLE IF NOT EXISTS subscription_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID REFERENCES subscriptions(id),
    user_id VARCHAR(255) NOT NULL,
    product_id VARCHAR(100) NOT NULL,
    platform VARCHAR(20) NOT NULL,
    order_id VARCHAR(255) NOT NULL,
    action VARCHAR(50) NOT NULL, -- 'purchased', 'renewed', 'cancelled', 'expired', 'upgraded', 'downgraded'
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for subscription history
CREATE INDEX idx_subscription_history_user_id ON subscription_history(user_id);
CREATE INDEX idx_subscription_history_subscription_id ON subscription_history(subscription_id);

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update the updated_at column
CREATE TRIGGER update_subscriptions_updated_at 
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to log subscription changes to history
CREATE OR REPLACE FUNCTION log_subscription_change()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO subscription_history (
            subscription_id, user_id, product_id, platform, 
            order_id, action, metadata
        ) VALUES (
            NEW.id, NEW.user_id, NEW.product_id, NEW.platform,
            NEW.order_id, 'purchased', 
            jsonb_build_object('auto_renewing', NEW.auto_renewing)
        );
    ELSIF TG_OP = 'UPDATE' THEN
        -- Log renewal
        IF OLD.expiry_date < NEW.expiry_date THEN
            INSERT INTO subscription_history (
                subscription_id, user_id, product_id, platform,
                order_id, action, metadata
            ) VALUES (
                NEW.id, NEW.user_id, NEW.product_id, NEW.platform,
                NEW.order_id, 'renewed',
                jsonb_build_object(
                    'old_expiry', OLD.expiry_date,
                    'new_expiry', NEW.expiry_date
                )
            );
        END IF;
        
        -- Log cancellation
        IF OLD.auto_renewing = true AND NEW.auto_renewing = false THEN
            INSERT INTO subscription_history (
                subscription_id, user_id, product_id, platform,
                order_id, action, metadata
            ) VALUES (
                NEW.id, NEW.user_id, NEW.product_id, NEW.platform,
                NEW.order_id, 'cancelled',
                jsonb_build_object('expiry_date', NEW.expiry_date)
            );
        END IF;
        
        -- Log product change (upgrade/downgrade)
        IF OLD.product_id != NEW.product_id THEN
            INSERT INTO subscription_history (
                subscription_id, user_id, product_id, platform,
                order_id, action, metadata
            ) VALUES (
                NEW.id, NEW.user_id, NEW.product_id, NEW.platform,
                NEW.order_id, 
                CASE 
                    WHEN NEW.product_id LIKE '%premium%' AND OLD.product_id LIKE '%basic%' THEN 'upgraded'
                    WHEN NEW.product_id LIKE '%basic%' AND OLD.product_id LIKE '%premium%' THEN 'downgraded'
                    ELSE 'changed'
                END,
                jsonb_build_object(
                    'old_product', OLD.product_id,
                    'new_product', NEW.product_id
                )
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to log subscription changes
CREATE TRIGGER log_subscription_changes
    AFTER INSERT OR UPDATE ON subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION log_subscription_change();

-- Grant permissions
GRANT ALL ON subscriptions TO examcoach;
GRANT ALL ON subscription_history TO examcoach;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO examcoach;
