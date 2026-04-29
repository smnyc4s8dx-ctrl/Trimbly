import Foundation

extension ProcessInfo {
    var machineType: String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
}

extension String {
    func matches(of pattern: String, options: NSRegularExpression.Options = []) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return matches.compactMap { match in
                Range(match.range, in: self).map { String(self[$0]) }
            }
        } catch {
            return []
        }
    }
}
