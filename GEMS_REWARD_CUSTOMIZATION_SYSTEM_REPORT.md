# MindDrift Gems & Reward System with Customization Integration

## Overview
MindDrift features a comprehensive gems and reward system that serves as the primary in-game economy, deeply integrated with the customization system. The system encourages player engagement through various reward mechanisms while providing extensive personalization options.

---

## 💎 **GEMS SYSTEM**

### **Core Currency: Mind Gems**
- **Primary In-Game Currency**: Mind Gems are the main virtual currency
- **Non-Premium Currency**: Earned through gameplay, not purchasable with real money
- **Persistent Balance**: Stored in user's `PlayerWallet` in Firestore
- **Transaction Logging**: All gem transactions are logged for transparency and analytics

### **Gem Earning Mechanisms**

#### **1. Daily Bonus System**
- **Amount**: 250 gems per day
- **Frequency**: Once per 24-hour period
- **Implementation**: `WalletService.claimDailyBonus()`
- **Cooldown**: Based on `lastDailyBonus` timestamp in user wallet

#### **2. Campaign Mode Rewards**
- **Star-Based Rewards**: Gems awarded for achieving stars in campaign levels
  - 1 Star: 25 gems
  - 2 Stars: 75 gems (cumulative)
  - 3 Stars: 150 gems (cumulative)
- **First-Time Only**: Rewards only given for first-time star achievement
- **Implementation**: `WalletService.awardCampaignStarGems()`

#### **3. Achievement System**
- **Milestone Rewards**: Large gem bonuses for major achievements
  - First Level: 50 gems
  - First Section: 100 gems
  - Perfect Level: 150 gems
  - Speed Runner: 200 gems
  - Star Collector: 300 gems
  - Campaign Master: 1000 gems

#### **4. Quest System Integration**
- **Quest Completion**: Gems awarded for completing daily/weekly quests
- **Progress Tracking**: `QuestService.trackProgress()` automatically awards gems
- **Avoid Double Rewards**: Quest completion gems are tracked separately to prevent circular dependencies

#### **5. Multiplayer Performance**
- **Round Completion**: Gems awarded based on performance in multiplayer rounds
- **Score-Based Rewards**: Higher accuracy and scores yield more gems
- **Team Performance**: Bonus gems for team achievements

### **Gem Spending System**

#### **1. Cosmetic Items**
- **Slider Skins**: Visual customization for the spectrum slider (500-2,500 gems)
- **Profile Badges**: Display badges for player profiles (1,500 gems)
- **Avatar Packs**: Collections of themed avatars (3,000-5,000 gems)

#### **2. Username Changes**
- **First Change**: Free
- **Subsequent Changes**: 1,000 gems per change
- **Implementation**: `PlayerWallet.usernameChangeCost` property

#### **3. Premium Features (Future)**
- **Power-ups**: Temporary gameplay enhancements
- **Exclusive Content**: Special bundles or features

---

## 🎮 **REWARD SYSTEM**

### **Player Wallet Model**
```dart
class PlayerWallet {
  final int mindGems;                    // Current gem balance
  final int totalGemsEarned;             // Lifetime earnings (statistics)
  final int totalGemsSpent;              // Lifetime spending (statistics)
  final DateTime lastDailyBonus;         // Daily bonus cooldown
  final List<String> ownedSliderSkins;   // Purchased slider skins
  final List<String> ownedBadges;        // Purchased badges
  final List<String> ownedAvatarPacks;   // Purchased avatar packs
  final int usernameChangesUsed;         // Username change counter
}
```

### **Transaction System**
- **Complete Audit Trail**: Every gem transaction is logged
- **Metadata Support**: Rich context for each transaction (level completed, item purchased, etc.)
- **Firestore Storage**: Transactions stored in `gem_transactions/{userId}/transactions/`
- **Analytics Ready**: Transaction data supports player behavior analysis

### **Reward Animations**
- **Visual Feedback**: `GemsRewardOverlay` shows gem earning animations
- **Contextual Display**: Animations appear when gems are earned through gameplay
- **User Engagement**: Celebratory animations increase satisfaction

---

## 🎨 **CUSTOMIZATION SYSTEM**

### **Avatar System**

#### **Free Avatars**
- **Default Pack**: 6 free avatars (bear, cat, dog, fox, lion, owl)
- **Always Available**: No gem cost, accessible to all players
- **SVG Format**: Scalable vector graphics for crisp display

#### **Premium Avatar Packs**
- **Pack Structure**: Each pack contains 6 themed avatars
- **Pricing**: 3,000-5,000 gems per pack
- **Themes Available**:
  - Horror Pack: Dark, spooky themed avatars
  - Kids Pack: Cute, child-friendly avatars
  - Food Pack: Culinary themed avatars
  - Nature Pack: Animal and nature themed avatars
  - Fantasy Pack: Mythical and magical avatars

#### **Custom Avatar Support**
- **Premium Feature**: Custom avatar uploads require premium subscription
- **Image Upload**: Users can upload their own avatar images
- **Cloud Storage**: Custom avatars stored in Firebase Storage
- **Active Management**: Users can set one custom avatar as active

### **Slider Skin System**

#### **Skin Categories**
- **Common Skins (500 gems)**:
  - Rainbow Spectrum: Colorful gradient
  - Neon Glow: Electric neon colors
  - Sunset Vibes: Warm sunset colors

- **Epic Skins (2,500 gems)**:
  - Galaxy Explorer: Deep space with star effects
  - Flame Master: Animated fire effects
  - Frozen Crystal: Icy blue with crystalline effects

#### **Skin Features**
- **Animated Effects**: Premium skins include particle effects and animations
- **Visual Enhancement**: Skins change the appearance of the spectrum slider
- **Rarity System**: Common, Rare, Epic, Legendary classifications

### **Badge System**

#### **Badge Types**
- **Achievement Badges**: Earned through gameplay milestones
- **Purchase Badges**: Available in gem store (1,500 gems each)
- **Prestige Badges**: Special badges for exceptional performance

#### **Badge Categories**
- **Golden Brain**: Prestigious badge for smart players
- **Mastermind Medal**: For mind game excellence
- **Lightning Fast**: For quick thinking
- **Social Badges**: For multiplayer achievements

---

## 🔗 **SYSTEM INTEGRATIONS**

### **Quest System Connection**
- **Progress Tracking**: Quest completion automatically awards gems
- **Milestone Rewards**: Large gem bonuses for quest achievements
- **Daily/Weekly Quests**: Regular gem income through quest completion
- **Avoid Circular Dependencies**: Quest gems are tracked separately from other rewards

### **Campaign Mode Integration**
- **Star Rewards**: Each campaign star earned grants gems
- **Level Completion**: Bonus gems for finishing levels
- **Section Completion**: Larger rewards for completing entire sections
- **Perfect Performance**: Extra gems for achieving perfect scores

### **Multiplayer Integration**
- **Performance Rewards**: Gems based on round performance
- **Team Bonuses**: Extra gems for team achievements
- **Participation Rewards**: Gems for active participation
- **Win Streaks**: Bonus gems for consecutive victories

### **Premium Subscription Benefits**
- **All Access Bundle**: Unlocks all current and future content
- **Custom Features**: Avatar customization, custom usernames
- **Enhanced Rewards**: Potential for increased gem earning rates
- **Exclusive Content**: Premium-only cosmetic items

---

## 💾 **DATA MANAGEMENT**

### **Firestore Collections**
- **`player_wallets`**: User gem balances and owned items
- **`gem_transactions`**: Complete transaction history
- **`quest_progress`**: Quest completion tracking
- **`custom_avatars`**: User-uploaded avatar data

### **Transaction Safety**
- **Atomic Operations**: All gem transactions use Firestore transactions
- **Consistency Guarantees**: Prevents negative balances and duplicate rewards
- **Error Handling**: Robust error handling with rollback capabilities
- **Concurrent Safety**: Multiple simultaneous transactions handled safely

### **Caching Strategy**
- **Local Wallet Cache**: Wallet data cached for quick access
- **Transaction History**: Recent transactions cached for UI display
- **Cosmetic Catalog**: Static catalog data cached locally

---

## 🎯 **GAMIFICATION FEATURES**

### **Progression Systems**
- **Lifetime Statistics**: Track total gems earned/spent
- **Achievement Unlocks**: New content unlocked through gem spending
- **Streak Bonuses**: Daily bonus encourages daily play
- **Collection Goals**: Encourage players to collect all cosmetic items

### **Social Features**
- **Profile Display**: Showcase purchased cosmetics to other players
- **Badge Prestige**: Display earned badges in multiplayer
- **Custom Avatars**: Unique personalization in social contexts

### **Retention Mechanics**
- **Daily Engagement**: Daily bonus encourages regular play
- **Long-term Goals**: Expensive cosmetic items provide long-term objectives
- **Collection Completion**: Completionist players have extensive goals
- **Exclusive Content**: Premium features encourage subscription

---

## 🔮 **FUTURE EXPANSION**

### **Planned Features**
- **Seasonal Events**: Limited-time cosmetic items and gem rewards
- **Battle Pass**: Tiered reward system with premium track
- **Social Rewards**: Gems for helping friends or community participation
- **Tournament Rewards**: Special gems for competitive play

### **Monetization Integration**
- **Gem Packs**: Potential future real-money gem purchases
- **Premium Subscription**: Enhanced gem earning rates
- **Exclusive Bundles**: Special gem store offers

---

## 📊 **ANALYTICS & METRICS**

### **Key Performance Indicators**
- **Gem Earning Rate**: Average gems earned per session
- **Gem Spending Patterns**: Popular cosmetic categories
- **Daily Active Users**: Daily bonus claim rates
- **Retention Metrics**: Player return rates based on gem rewards

### **Business Intelligence**
- **Popular Items**: Most purchased cosmetic items
- **Player Progression**: Gem earning/spending over time
- **Engagement Correlation**: Relationship between rewards and play time
- **Monetization Potential**: Conversion rates from free to premium features

---

## 🛠 **TECHNICAL IMPLEMENTATION**

### **Core Services**
- **`WalletService`**: Central gem management service
- **`QuestService`**: Quest progress and reward tracking
- **`SkinManager`**: Cosmetic item management
- **`PurchaseProvider`**: Premium subscription management

### **Data Models**
- **`PlayerWallet`**: Core wallet data structure
- **`GemTransaction`**: Transaction logging model
- **`CosmeticItem`**: Cosmetic item definition
- **`Avatar`**: Avatar data structure

### **UI Components**
- **`GemStoreScreen`**: Main gem store interface
- **`GemsRewardOverlay`**: Reward animation component
- **`CosmeticPreview`**: Item preview components
- **`WalletDisplay`**: Gem balance display

---

This comprehensive gems and reward system creates a robust economy that encourages player engagement while providing extensive customization options. The system is designed to be fair, transparent, and rewarding, with clear progression paths and meaningful choices for players to make with their earned gems.
