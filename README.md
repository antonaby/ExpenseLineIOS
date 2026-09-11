# Percent Budget

An iOS app for tracking personal spending, built around one core idea: instead of setting a fixed dollar cap per category, you set a **percentage of your total budget**.

> "I don't want to spend more than 10% of my budget on sushi."

You define your overall budget for a period, then assign percentage-based limits to individual spending categories (or specific things you're trying to watch, like eating out or subscriptions). The app tracks your transactions and shows how close you are to each limit in real time, so you catch overspending on the categories that matter before it happens — without having to guess a fixed number that stops making sense when your income or total budget changes.

## Core concepts

- **Budget** — a total amount you plan to spend over a period (e.g. weekly, monthly).
- **Category limits** — each spending category can have a max share of the budget (e.g. 10% on dining, 5% on entertainment).
- **Transactions** — individual expenses logged against categories, which roll up into progress toward each category's limit.
- **Notifications** — alerts when a category is approaching or has exceeded its percentage cap.

## Tech stack

- SwiftUI for the UI
- Core Data for local persistence (`DataContainer.xcdatamodeld`)
- Firebase (Analytics, config via `GoogleService-Info.plist`)
- StoreKit for in-app subscriptions

## Project structure

- `Models/` — core data types: `Budget`, `Category`, `Transaction`, `Period`, `Currency`, etc.
- `Services/` — business logic and data access: `BudgetService`, `DataService`, `NotificationService`, `SubscriptionManager`, etc.
- `Modules/` — feature screens (Budgets, Transactions, Category, Settings, Notifications, Wizard, Main)
- `Components/` — shared SwiftUI views (progress rings, cards, form controls)
- `Extensions/` — Swift standard library and Foundation extensions used across the app

## Getting started

Open `ExpenseLineIOS.xcodeproj` in Xcode and run the `ExpenseLineIOS` scheme on a simulator or device.
