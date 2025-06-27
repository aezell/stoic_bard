# Shakespearean Stoic Life Coach - Web Application

Build a responsive web application called "The Bard's Wisdom" that combines Marcus Aurelius's stoic philosophy with Shakespeare's eloquent language to provide daily life coaching.

## Core Concept
Users answer 4-5 reflective questions about their current state of mind, challenges, and emotions. The app then uses the Claude API to generate personalized advice written in a "Shakespearean Stoic" voice - delivering Marcus Aurelius's practical wisdom through Shakespeare's poetic language.

## Technical Requirements

### Frontend
- **Framework**: Phoenix Framework with Elixir
- **Styling**: Tailwind CSS and DaisyUI for responsive design
- **Mobile-first**: Optimized for phone screens, works well on desktop
- **Design aesthetic**: Renaissance-inspired but modern - think elegant typography, warm colors (deep blues, golds, creams), subtle parchment textures

### Backend/API Integration
- **Claude API**: Use Anthropic's Claude API (claude-sonnet-4-20250514)
- **Environment**: Elixir backend or serverless functions
- **API Key**: Store securely in environment variables

## User Experience Flow

### 1. Landing Page
- Elegant welcome screen with app title and tagline
- Brief explanation of the concept
- "Begin Today's Reflection" button

### 2. Question Flow
Present these 5 questions one at a time with smooth transitions:

1. **"What challenge weighs most heavily upon thy mind today?"**
   - Text area for user response
   - Placeholder: "Speak freely of what troubles thee..."

2. **"How didst thou respond when last faced with frustration or setback?"**
   - Text area for response
   - Placeholder: "Reflect upon thy recent trials..."

3. **"What task or conversation dost thou avoid, though thou knowest it must be faced?"**
   - Text area for response
   - Placeholder: "What duties call to thee unheeded..."

4. **"Where did gratitude find thee in yesterday's hours?"**
   - Text area for response
   - Placeholder: "Recall thy moments of thankfulness..."

5. **"What relationship in thy life seeketh thy greater attention?"**
   - Text area for response
   - Placeholder: "Consider thy bonds with others..."

### 3. Loading Screen
- Show while generating advice
- Elegant animation or quote about wisdom
- "The Bard considers thy words..."

### 4. Advice Display
- Beautiful, readable typography
- Scroll-friendly format
- Share button for social media
- "Reflect Again" button to start over

## Claude API Integration

### System Prompt
```
You are the Shakespearean Stoic, a wise philosopher who combines the practical wisdom of Marcus Aurelius with the eloquent language of William Shakespeare. You provide life advice that is:

1. Grounded in stoic principles: acceptance, focus on what one can control, impermanence, duty, inner peace, and rational thinking
2. Expressed in Shakespearean language: rich metaphors, iambic rhythm, archaic terms (thou, thy, dost, etc.), and poetic imagery
3. Compassionate yet firm, offering both comfort and challenge
4. Relevant to modern life while maintaining the classical voice

Draw upon themes from Shakespeare's plays and Marcus Aurelius's Meditations. Use "thou," "thy," "dost," and other period language naturally. Include metaphors from nature, theater, and life's journey.

Respond to the human's five answers with personalized advice of 200-300 words that addresses their specific situations while maintaining the philosophical voice.
```

### API Call Structure
- Combine all user responses into a single API call
- Include system prompt + user context
- Handle errors gracefully
- Implement retry logic

## UI/UX Specifications

### Color Palette
- Primary: Deep royal blue (#1e3a8a)
- Secondary: Warm gold (#f59e0b)
- Background: Cream (#fefdf8)
- Text: Dark charcoal (#1f2937)
- Accent: Burgundy (#7c2d12)

### Typography
- Headers: Serif font (Playfair Display or similar)
- Body text: Clean, readable sans-serif
- Advice text: Elegant serif for readability

### Mobile Responsiveness
- Single column layout on mobile
- Large, touch-friendly buttons
- Proper spacing and padding
- Text areas that expand naturally
- Smooth transitions between screens

### Animations
- Subtle fade-ins and slide transitions
- Loading animations while generating advice
- Gentle hover effects on interactive elements

## Technical Implementation Notes

### API Security
- Never expose API keys in frontend code
- Use environment variables for sensitive data
- Implement rate limiting to prevent abuse

### Performance
- Lazy load components
- Optimize images and assets
- Consider caching common responses (with user permission)

### Error Handling
- Graceful fallbacks if API is unavailable
- Clear error messages in the app's voice
- Retry mechanisms for failed requests

### Data Handling
- Don't store user responses permanently (unless explicitly opted in)
- Respect user privacy
- Consider adding optional account creation for history

## Additional Features to Consider
- Daily reminder notifications
- Favorite/save advice feature
- Different philosophical "moods" (Hamlet-esque for introspection, Henry V for courage)
- Social sharing with beautiful quote cards

## File Structure
You already have a scaffold for a Phoenix app in this directory created by using `mix phx.new stoic_bard`

Build this as a polished, production-ready application with proper error handling, beautiful design, and smooth user experience. The goal is to create something that feels both timeless and modern, helping users find wisdom in their daily lives through the marriage of two great philosophical traditions.