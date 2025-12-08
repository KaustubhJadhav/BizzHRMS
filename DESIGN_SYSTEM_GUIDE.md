# BizzHRMS Design System Guide

This document outlines the design system used in the BizzHRMS Flutter application, specifically the modern home screen redesign. This design follows **Material Design 3** principles with a clean, professional aesthetic.

## 🎨 Design Philosophy

### Core Principles
1. **Clean & Minimal**: White cards on light background with subtle shadows
2. **Color-First Icons**: Icons use brand colors in circular containers with subtle backgrounds
3. **Consistent Spacing**: 8px base unit system for all spacing
4. **Soft Shadows**: Color-tinted shadows that match icon colors for depth
5. **Modern Typography**: Clear hierarchy with proper font weights
6. **Gradient Accents**: Used sparingly for hero elements (welcome card)

---

## 🎨 Color System

### Primary Palette
```dart
// Primary Colors
primaryColor: Color(0xFF2C3E50)      // Dark blue-gray (main brand)
secondaryColor: Color(0xFF3498DB)    // Bright blue (actions)
accentColor: Color(0xFFE74C3C)        // Red (errors, warnings)
successColor: Color(0xFF27AE60)       // Green (success states)
warningColor: Color(0xFFF39C12)      // Orange (warnings)

// Background Colors
backgroundColor: Color(0xFFF5F6FA)     // Light gray background
cardBackgroundColor: Colors.white     // Pure white for cards

// Text Colors
textPrimaryColor: Color(0xFF2C3E50)   // Dark text
textSecondaryColor: Color(0xFF7F8C8D) // Gray text
```

### Color Usage Pattern
- **Cards**: White background (`Colors.white`)
- **Icons**: Brand colors (each feature has its own color)
- **Icon Backgrounds**: `color.withOpacity(0.1)` - subtle tinted circles
- **Shadows**: `color.withOpacity(0.15)` - color-matched shadows
- **Gradients**: Primary color to primary with 0.8 opacity

---

## 📐 Spacing System

### Base Unit: 8px
All spacing follows an 8px grid system:

```dart
// Common Spacing Values
const double spacing4 = 4.0;    // Very tight spacing
const double spacing8 = 8.0;    // Base unit
const double spacing12 = 12.0;  // Card internal spacing
const double spacing16 = 16.0;  // Standard padding
const double spacing20 = 20.0;  // Card padding
const double spacing24 = 24.0;  // Section spacing
```

### Usage Examples
- **Card Padding**: `16.0` or `20.0`
- **Grid Spacing**: `12.0` (between cards)
- **Section Spacing**: `24.0` (between major sections)
- **Icon Padding**: `12.0` (inside circular containers)
- **Text Spacing**: `4.0` to `8.0` (between text elements)

---

## 🔤 Typography

### Text Theme Hierarchy
```dart
displayLarge:  32px, bold    // Hero text
displayMedium: 28px, bold    // Large headings
displaySmall:  24px, bold    // Section headings
headlineMedium: 20px, w600   // Card titles
titleLarge:    18px, w600    // Subsection titles
bodyLarge:     16px, normal  // Body text
bodyMedium:    14px, normal  // Secondary text
bodySmall:     12px, normal  // Captions (gray)
```

### Usage Guidelines
- **Welcome Card Title**: `headlineMedium` with white color
- **Card Titles**: `titleLarge` with bold weight
- **Body Text**: `bodyLarge` or `bodyMedium`
- **Placeholder Text**: `bodyLarge` with gray color (`Colors.grey`)

---

## 🎴 Card Design Patterns

### 1. Navigation Cards (Home Screen Grid)

**Structure:**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.15),  // Color-matched shadow
        blurRadius: 8,
        offset: Offset(0, 2),
        spreadRadius: 0,
      ),
    ],
  ),
  child: Column(
    children: [
      // Icon in circular container
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),  // Subtle tint
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 28, color: color),
      ),
      SizedBox(height: 12),
      // Title text
      Text(title, style: bodyMedium with w600),
    ],
  ),
)
```

**Key Features:**
- **Border Radius**: `16px` (rounded corners)
- **Shadow**: Color-matched, subtle (`0.15` opacity)
- **Icon Container**: Circular with `0.1` opacity background
- **Icon Size**: `28px`
- **Aspect Ratio**: `1.0` (square cards in 3-column grid)

### 2. Welcome/Hero Card

**Structure:**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary.withOpacity(0.8),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

**Key Features:**
- **Gradient**: Primary color to slightly transparent
- **Shadow**: Stronger shadow (`0.3` opacity, `12px` blur)
- **White Text**: All text is white for contrast
- **Icon Badge**: White with `0.2` opacity background

### 3. Standard Content Cards

**Structure:**
```dart
Card(
  elevation: 0,  // No default elevation
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(...),
  ),
)
```

**Key Features:**
- **Border Radius**: `16px` consistently
- **Elevation**: `0` (using shadows instead)
- **Padding**: `16px` or `20px`

---

## 🌈 Shadow System

### Shadow Patterns

**Navigation Cards:**
```dart
BoxShadow(
  color: color.withOpacity(0.15),  // Color-matched
  blurRadius: 8,
  offset: Offset(0, 2),
  spreadRadius: 0,
)
```

**Hero Cards:**
```dart
BoxShadow(
  color: primaryColor.withOpacity(0.3),
  blurRadius: 12,
  offset: Offset(0, 4),
)
```

**Stat Cards:**
```dart
BoxShadow(
  color: color.withOpacity(0.1),
  blurRadius: 4,
  offset: Offset(0, 2),
)
```

### Shadow Principles
- **Color-Matched**: Shadows use the same color as the element
- **Subtle**: Low opacity (0.1 to 0.15) for cards
- **Directional**: Always `Offset(0, Y)` for depth
- **No Spread**: `spreadRadius: 0` for clean edges

---

## 📏 Border Radius System

### Standard Radius Values
```dart
const double radius8 = 8.0;   // Small elements (buttons, inputs)
const double radius12 = 12.0; // Medium elements (stat cards)
const double radius16 = 16.0; // Large elements (main cards)
```

### Usage
- **Navigation Cards**: `16px`
- **Welcome Card**: `16px`
- **Icon Containers**: `12px` (circular, but defined for consistency)
- **Buttons**: `8px` or `12px`
- **Input Fields**: `8px` or `12px`

---

## 🎯 Icon Design Pattern

### Icon Container Pattern
```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: color.withOpacity(0.1),  // Subtle background
    shape: BoxShape.circle,          // Always circular
  ),
  child: Icon(
    icon,
    size: 28,                        // Standard size
    color: color,                    // Brand color
  ),
)
```

### Icon Sizes
- **Navigation Cards**: `28px`
- **Welcome Card**: `24px`
- **Stat Cards**: `8px` (small indicator)
- **Buttons**: `18px`

---

## 📱 Layout Patterns

### Grid Layout
```dart
GridView.count(
  crossAxisCount: 3,           // Fixed 3 columns
  crossAxisSpacing: 12,         // Horizontal spacing
  mainAxisSpacing: 12,          // Vertical spacing
  childAspectRatio: 1.0,        // Square cards
)
```

### Card Layout
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Title
    Text(title, style: titleLarge),
    SizedBox(height: 16),
    // Content
    Expanded(child: content),
  ],
)
```

---

## 🎨 Component Examples

### Button Styles

**Filled Button (Primary Action):**
```dart
FilledButton.icon(
  style: FilledButton.styleFrom(
    backgroundColor: isActive ? Colors.red.shade400 : Colors.white,
    foregroundColor: isActive ? Colors.white : primaryColor,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
  ),
)
```

### Section Titles
```dart
Text(
  'Quick Access',
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
  ),
)
```

---

## 🔄 Interaction Patterns

### Tap Feedback
- **Material InkWell**: Standard Material ripple effect
- **Border Radius**: Matches card radius (`16px`)
- **No Elastic Animation**: Clean, standard Material interactions

### Navigation
- **Immediate Navigation**: No delays or animations
- **Standard Transitions**: Material page transitions
- **Route Highlighting**: Active route highlighted in sidebar

---

## 📋 Best Practices

### Do's ✅
- Use white cards on light background
- Apply color-matched shadows
- Use circular icon containers with subtle backgrounds
- Maintain 8px spacing grid
- Use 16px border radius for cards
- Keep shadows subtle (0.15 opacity)
- Use theme colors consistently

### Don'ts ❌
- Don't use gradients on regular cards (only hero elements)
- Don't use heavy shadows (keep opacity low)
- Don't mix border radius sizes (stick to 8, 12, 16)
- Don't use flat colors without shadows
- Don't break the 8px spacing grid
- Don't use too many colors (stick to brand palette)

---

## 🎯 Quick Reference

### Color Opacity Guide
- **Icon Backgrounds**: `0.1` (very subtle)
- **Card Shadows**: `0.15` (subtle depth)
- **Hero Shadows**: `0.3` (more prominent)
- **Text Overlays**: `0.9` (semi-transparent white)

### Spacing Quick Reference
- **Tight**: `4px` - Between related elements
- **Standard**: `12px` - Card internal spacing
- **Comfortable**: `16px` - Card padding
- **Section**: `24px` - Between major sections

### Border Radius Quick Reference
- **Small**: `8px` - Buttons, inputs
- **Medium**: `12px` - Stat cards, badges
- **Large**: `16px` - Main cards, containers

---

## 🚀 Implementation Tips

1. **Always use Theme.of(context)** for colors and text styles
2. **Extract common values** to constants for consistency
3. **Use Material widgets** (InkWell, Card) for proper interactions
4. **Test on different screen sizes** - grid adapts but spacing stays consistent
5. **Maintain color consistency** - each feature should have its own color
6. **Keep shadows subtle** - they should add depth, not dominate

---

## 📚 Related Files

- `lib/config/theme/app_theme.dart` - Theme configuration
- `lib/presentation/home/view/home_page.dart` - Implementation examples
- `lib/presentation/shared/widgets/` - Reusable components

---

This design system creates a **modern, clean, and professional** look that's easy to maintain and extend. The color-first approach with subtle shadows and consistent spacing creates visual hierarchy while maintaining a cohesive brand identity.

