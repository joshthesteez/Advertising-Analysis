import pandas as pd
import numpy as np
from datetime import datetime

def generate_synthetic_ad_data(num_samples=1000, seed=42):
    """
    Generate synthetic advertising data with distributions matching provided statistics.
    
    Parameters:
    -----------
    num_samples : int
        Number of samples to generate
    seed : int
        Random seed for reproducibility
        
    Returns:
    --------
    pandas.DataFrame
        Synthetic dataset with similar structure and distributions
    """
    # Initialize random state with timestamp-based variation
    current_seed = seed + int(datetime.now().timestamp()) % 10000
    rng = np.random.RandomState(current_seed)
    
    # Define categorical values
    ad_types = ['2D', '3D', 'AR']
    visual_complexity = ['Low', 'Medium', 'High']
    age_groups = ['18-24', '25-34', '35-44', '45-54', '55+']
    genders = ['Male', 'Female']
    device_types = ['Mobile', 'Desktop', 'Tablet']
    
    # Generate synthetic data
    data = {
        'Ad_ID': range(1, num_samples + 1),
        'Ad_Type': rng.choice(ad_types, num_samples, p=[0.4, 0.35, 0.25]),
        'Visual_Complexity': rng.choice(visual_complexity, num_samples, p=[0.3, 0.4, 0.3]),
        
        # Clicks: mean between 115-175, bounded 5-315
        'Clicks': rng.lognormal(4.9, 0.6, num_samples).clip(5, 315).astype(int),
        
        # Time_Spent: right-skewed distribution in seconds
        'Time_Spent': rng.gamma(shape=2, scale=15, size=num_samples).astype(int).clip(1, None),
        
        # Engagement_Score: normal distribution between 60-95
        'Engagement_Score': rng.normal(77.5, 7, num_samples).clip(60, 95).astype(int),
        
        # Categorical variables with specified proportions
        'Age_Group': rng.choice(age_groups, num_samples, p=[0.25, 0.3, 0.2, 0.15, 0.1]),
        'Gender': rng.choice(genders, num_samples, p=[0.52, 0.48]),
        'Device_Type': rng.choice(device_types, num_samples, p=[0.55, 0.35, 0.1]),
    }
    
    # Create DataFrame
    df = pd.DataFrame(data)
    
    # Generate realistic rates with beta distributions and proper scaling
    # CTR: Between 5-12%
    raw_ctr = rng.beta(5, 35, num_samples)
    df['CTR'] = (raw_ctr * (12 - 5) + 5).clip(5, 12)
    
    # Conversion Rate: Keep existing distribution
    df['Conversion_Rate'] = rng.beta(1.2, 50, num_samples) * 100
    
    # Bounce Rate: Between 15-30%
    raw_bounce = rng.beta(4, 8, num_samples)
    df['Bounce_Rate'] = (raw_bounce * (30 - 15) + 15).clip(15, 30)
    
    # Generate mock tracking data
    df['Frame_Data'] = [f"frame_sequence_{i}" for i in range(num_samples)]
    df['User_Movement_Data'] = [f"movement_pattern_{i}" for i in range(num_samples)]
    
    # Add numeric encodings
    df['Age_Group_Numeric'] = pd.Categorical(df['Age_Group']).codes
    df['Movement_Numeric'] = rng.randint(0, 5, num_samples)
    df['Visual_Complexity_Numeric'] = pd.Categorical(df['Visual_Complexity']).codes
    df['Ad_Type_Numeric'] = pd.Categorical(df['Ad_Type']).codes
    
    return df

# Example usage
if __name__ == "__main__":
    # Generate synthetic dataset
    synthetic_data = generate_synthetic_ad_data(1000)
    
    # Display summary statistics
    print("\nSummary statistics of numerical columns:")
    print(synthetic_data.describe())
    
    # Display frequency distributions of categorical variables
    for col in ['Ad_Type', 'Visual_Complexity', 'Age_Group', 'Gender', 'Device_Type']:
        print(f"\nFrequency distribution for {col}:")
        print(synthetic_data[col].value_counts(normalize=True).round(3))
    
    # Save to CSV (optional)
    synthetic_data.to_csv('new_campaign_1.csv', index=False)