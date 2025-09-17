import Foundation

public struct NotificationSettings: Codable, Equatable, Sendable {
    public var reminderTimes: [DateComponents]
    public var enableMilestones: Bool
    public var highRiskLookbackDays: Int

    public init(
        reminderTimes: [DateComponents] = NotificationSettings.defaultReminderTimes,
        enableMilestones: Bool = true,
        highRiskLookbackDays: Int = 7
    ) {
        self.reminderTimes = reminderTimes
        self.enableMilestones = enableMilestones
        self.highRiskLookbackDays = max(1, highRiskLookbackDays)
    }

    public static var defaultReminderTimes: [DateComponents] {
        [9, 14, 21].map { hour in
            DateComponents(calendar: Calendar.autoupdatingCurrent, hour: hour, minute: 0)
        }
    }
}

public struct UserSettings: Codable, Equatable, Sendable {
    public var theme: AppTheme
    public var accentColor: AccentColor
    public var enableICloudSync: Bool
    public var notificationSettings: NotificationSettings

    public init(
        theme: AppTheme = .system,
        accentColor: AccentColor = AccentColor(red: 0.2, green: 0.6, blue: 0.4),
        enableICloudSync: Bool = false,
        notificationSettings: NotificationSettings = NotificationSettings()
    ) {
        self.theme = theme
        self.accentColor = accentColor
        self.enableICloudSync = enableICloudSync
        self.notificationSettings = notificationSettings
    }
}
