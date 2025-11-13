import { Language } from "../LangSelector/types";
import { FooterLinkType } from "./types";
import { TwitterIcon, TelegramIcon, RedditIcon, InstagramIcon, GithubIcon, DiscordIcon, YoutubeIcon } from "../Svg";

export const footerLinks: FooterLinkType[] = [
  {
    label: "About",
    items: [
      {
        label: "Contact",
        href: "https://cryptoswap.com/contact",
      },
      {
        label: "Blog",
        href: "https://blog.cryptoswap.com/",
      },
      {
        label: "Community",
        href: "https://t.me/cryptoswap",
      },
      {
        label: "Docs",
        href: "https://docs.cryptoswap.com/",
      },
    ],
  },
  {
    label: "Help",
    items: [
      {
        label: "Customer Support",
        href: "mailto:support@cryptoswap.com",
      },
      {
        label: "Troubleshooting",
        href: "https://docs.cryptoswap.com/help/troubleshooting",
      },
      {
        label: "Guides",
        href: "https://docs.cryptoswap.com/get-started",
      },
    ],
  },
  {
    label: "Developers",
    items: [
      {
        label: "Github",
        href: "https://github.com/Customkleinsllc",
      },
      {
        label: "Documentation",
        href: "https://docs.cryptoswap.com",
      },
      {
        label: "API",
        href: "https://docs.cryptoswap.com/api",
      },
      {
        label: "Security",
        href: "https://cryptoswap.com/security",
      },
    ],
  },
];

export const socials = [
  {
    label: "Twitter",
    icon: TwitterIcon,
    href: "https://twitter.com/cryptoswap",
  },
  {
    label: "Telegram",
    icon: TelegramIcon,
    href: "https://t.me/cryptoswap",
  },
  {
    label: "Discord",
    icon: DiscordIcon,
    href: "https://discord.gg/cryptoswap",
  },
  {
    label: "Instagram",
    icon: InstagramIcon,
    href: "https://instagram.com/cryptoswap_official",
  },
  {
    label: "Github",
    icon: GithubIcon,
    href: "https://github.com/Customkleinsllc",
  },
  {
    label: "Youtube",
    icon: YoutubeIcon,
    href: "https://www.youtube.com/@cryptoswap_official",
  },
];

export const langs: Language[] = [...Array(20)].map((_, i) => ({
  code: `en${i}`,
  language: `English${i}`,
  locale: `Locale${i}`,
}));
