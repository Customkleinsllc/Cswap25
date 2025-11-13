import { Select } from '@CryptoSwap/uikit'
import { languageList, useTranslation } from '@CryptoSwap/localization'
import { EN } from '@CryptoSwap/localization/src/config/languages'
import { SettingField } from './SettingField'

const langOptions = languageList.map((v) => ({
  label: v.language,
  value: v.code
}))

export function LanguageSettingField() {
  const { t, currentLanguage, setLanguage } = useTranslation()
  // const onChange = (v: string) => changeLang(v ?? 'zh-CN' /* Temp */)

  return (
    <SettingField
      fieldName={t('Language')}
      tooltip={t('Select preferred language')}
      renderToggleButton={
        <Select
          defaultOptionIndex={langOptions.findIndex((v) => v.value === currentLanguage.code) + 1}
          options={langOptions}
          onOptionChange={(option) => {
            setLanguage(languageList.find((v) => v.code === option.value) ?? EN)
          }}
          listStyle={{ maxHeight: '200px', overflowY: 'auto' }}
          // renderTriggerItem={(v) => <Text fontSize="sm">{v && getLangName(v)}</Text>}
        />
      }
    />
  )
}
