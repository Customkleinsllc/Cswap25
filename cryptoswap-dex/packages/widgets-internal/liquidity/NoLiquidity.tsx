import { useTranslation } from "@CryptoSwap/localization";
import { Text } from "@CryptoSwap/uikit";

export function NoLiquidity() {
  const { t } = useTranslation();

  return (
    <Text color="textSubtle" textAlign="center">
      {t("No liquidity found.")}
    </Text>
  );
}
