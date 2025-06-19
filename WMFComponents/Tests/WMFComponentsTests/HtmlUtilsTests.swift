import XCTest
@testable import WMFComponents

final class HtmlUtilsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStringFromHtml() {
        let text = "Testing here with <b>tags</b> &amp; &quot;multiple&quot; entities."
        let expectedText = "Testing here with tags & \"multiple\" entities."
        let result = try? HtmlUtils.stringFromHTML(text)
        XCTAssertNotNil(result, "Unexpected result when attempting to strip html and entities.")
        XCTAssertEqual(result, expectedText, "Unexpected result when attempting to strip html and entities.")
    }

    func testMalformedListHtml() throws {

        let html = "<div class=\"mw-fr-edit-messages\"><div class=\"cdx-message mw-fr-message-box cdx-message--inline cdx-message--notice\"><span class=\"cdx-message__icon\"></span><div class=\"cdx-message__content\"><p><b>Note:</b> Edits to this page from new or unregistered users are subject to review prior to publication (<a href=\"/wiki/Wikipedia:Pending_changes\" title=\"Wikipedia:Pending changes\">help</a>).\n</p><div id=\"mw-fr-logexcerpt\"><ul class=\'mw-logevent-loglines\'>\n<li data-mw-logid=\"166878532\" data-mw-logaction=\"stable/config\" class=\"mw-logline-stable\"> <a href=\"/w/index.php?title=Special:Log&amp;logid=166878532\" title=\"Special:Log\">21:42, 2 January 2025</a> <a href=\"/wiki/User:Ymblanter\" class=\"mw-userlink\" title=\"User:Ymblanter\"><bdi>Ymblanter</bdi></a> configured pending changes settings for <a href=\"/wiki/Josh_Allen\" title=\"Josh Allen\">Josh Allen</a> [Auto-accept: require &quot;autoconfirmed&quot; permission] (expires 21:42, 2 January 2026 (UTC)) <span class=\"comment\">(Persistent <a href=\"/wiki/Wikipedia:Vandalism\" title=\"Wikipedia:Vandalism\">vandalism</a>; requested at <a href=\"/wiki/Wikipedia:RfPP\" class=\"mw-redirect\" title=\"Wikipedia:RfPP\">WP:RfPP</a> (<a href=\"/wiki/Wikipedia:TW\" class=\"mw-redirect\" title=\"Wikipedia:TW\">TW</a>))</span> <span class=\"mw-logevent-actionlink\">(<a href=\"/w/index.php?title=Josh_Allen&amp;action=history&amp;offset=20250102214253\" title=\"Josh Allen\">hist</a>)</span> </li>\n</ul></ul>\n</div></div></div></div>"

        let largeTraitCollection = UITraitCollection(preferredContentSizeCategory: .large)
        let styles: HtmlUtils.Styles = HtmlUtils.Styles(font: WMFFont.for(.callout, compatibleWith: largeTraitCollection), boldFont: WMFFont.for(.boldCallout, compatibleWith: largeTraitCollection), italicsFont: WMFFont.for(.italicCallout, compatibleWith: largeTraitCollection), boldItalicsFont: WMFFont.for(.boldItalicCallout, compatibleWith: largeTraitCollection), color: WMFTheme.light.text, linkColor: WMFTheme.light.link, lineSpacing: 3)
        let attributedString = try HtmlUtils.attributedStringFromHtml(html, styles: styles)
        XCTAssertNotNil(attributedString, "Test extra unordered list did not cause crash")
    }

    func testHTMLLinkParsingWithNonEnglishCharacters() throws {
        let largeTraitCollection = UITraitCollection(preferredContentSizeCategory: .large)
        let styles = HtmlUtils.Styles(
            font:  WMFFont.for(.callout, compatibleWith: largeTraitCollection),
            boldFont: WMFFont.for(.boldCallout, compatibleWith: largeTraitCollection),
            italicsFont: WMFFont.for(.italicCallout, compatibleWith: largeTraitCollection),
            boldItalicsFont: WMFFont.for(.boldItalicCallout, compatibleWith: largeTraitCollection),
            color: WMFTheme.light.text,
            linkColor: WMFTheme.light.link,
            lineSpacing: 1
        )

        let htmlSamples: [(html: String, expectedHref: String, expectedText: String)] = [
            // Portuguese
            (
                "<a href=\"https://pt.wikipedia.org/wiki/Usuário:Rpo.castro_(discussão)\">discussão</a>",
                "https://pt.wikipedia.org/wiki/Usuário:Rpo.castro_(discussão)",
                "discussão"
            ),
            // Chinese
            (
                "<a href=\"https://zh.wikipedia.org/wiki/用戶:示例\">示例</a>",
                "https://zh.wikipedia.org/wiki/用戶:示例",
                "示例"
            ),
            // Japanese
            (
                "<a href=\"https://ja.wikipedia.org/wiki/利用者:テスト\">テスト</a>",
                "https://ja.wikipedia.org/wiki/利用者:テスト",
                "テスト"
            ),
            // Arabic
            (
                "<a href=\"https://ar.wikipedia.org/wiki/مستخدم:اختبار\">اختبار</a>",
                "https://ar.wikipedia.org/wiki/مستخدم:اختبار",
                "اختبار"
            ),
            // Hebrew
            (
                "<a href=\"https://he.wikipedia.org/wiki/משתמש:בדיקה\">בדיקה</a>",
                "https://he.wikipedia.org/wiki/משתמש:בדיקה",
                "בדיקה"
            ),
            // Percent-encoded '%'
            (
                "<a href=\"https://en.wikipedia.org/wiki/Williams_%25R\">Williams\u{00A0}%R</a>",
                "https://en.wikipedia.org/wiki/Williams_%25R",
                "Williams\u{00A0}%R"
            ),
            (
                "<a href=\"https://pt.wikipedia.org/wiki/3%25\">3%</a>",
                "https://pt.wikipedia.org/wiki/3%25",
                "3%"
            ),
            (
                "<a href=\"https://en.wikipedia.org/wiki/User_talk:Kwamikagami#Instruction_to_click_%22disable%22\">Instruction to click \"disable\"</a>",
                "https://en.wikipedia.org/wiki/User_talk:Kwamikagami#Instruction_to_click_%22disable%22",
                "Instruction to click \"disable\""
            )
        ]

        for (html, expectedHref, expectedText) in htmlSamples {
            try XCTContext.runActivity(named: html) { _ in
                let attributed = try HtmlUtils.nsAttributedStringFromHtml(html, styles: styles)
                let fullRange = NSRange(location: 0, length: attributed.length)

                var found: [(url: URL, range: NSRange)] = []
                attributed.enumerateAttribute(.link,
                                              in: fullRange,
                                              options: []) { value, range, _ in
                    switch value {
                    case let url as URL:
                        found.append((url, range))
                    case let str as String where URL(string: str) != nil:
                        found.append((URL(string: str)!, range))
                    default:
                        break
                    }
                }

                if found.count != 1 {
                    let attrsAtZero = attributed.attributes(at: 0, effectiveRange: nil)
                    XCTFail("Expected exactly 1 link but found \(found.count).\nAttributes at index 0: \(attrsAtZero)")
                    return
                }

                let (url, range) = found[0]

                XCTAssertEqual(range, fullRange,
                               "Link range should cover the whole string, but was \(range)")

                XCTAssertEqual(url, URL(string: expectedHref)!,
                               "URL mismatch — got \(url), expected \(expectedHref)")

                XCTAssertEqual(attributed.string, expectedText,
                               "Anchor text mismatch — got “\(attributed.string)”, expected “\(expectedText)”")
            }
        }
    }

    func testNoLinksInPlainText() throws {
        let largeTraitCollection = UITraitCollection(preferredContentSizeCategory: .large)
        let styles = HtmlUtils.Styles(
            font:  WMFFont.for(.callout, compatibleWith: largeTraitCollection),
            boldFont: WMFFont.for(.boldCallout, compatibleWith: largeTraitCollection),
            italicsFont: WMFFont.for(.italicCallout, compatibleWith: largeTraitCollection),
            boldItalicsFont: WMFFont.for(.boldItalicCallout, compatibleWith: largeTraitCollection),
            color: WMFTheme.light.text,
            linkColor: WMFTheme.light.link,
            lineSpacing: 1
        )
        let plain = "This is just text with no <a> tags."
        let attributed = try HtmlUtils.nsAttributedStringFromHtml(plain, styles: styles)
        let fullRange = NSRange(location: 0, length: attributed.length)
        var linkCount = 0

        attributed.enumerateAttribute(.link,
                                      in: fullRange,
                                      options: []) { value, _, _ in
            if value != nil { linkCount += 1 }
        }

        XCTAssertEqual(linkCount, 0, "Plain text should not produce any .link attributes")
    }

}
