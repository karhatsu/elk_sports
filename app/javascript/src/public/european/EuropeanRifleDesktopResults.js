import React from 'react'
import { resolveClubTitle } from '../../util/clubUtil'
import useTranslation from '../../util/useTranslation'
import DesktopResultsRows from '../series-results/DesktopResultsRows'
import ShootingResult from '../series-results/ShootingResult'
import TotalScore from '../series-results/TotalScore'
import EuropeanRifleNationalRecord from './EuropeanRifleNationalRecord'

export default function EuropeanRifleDesktopResults({ race, series }) {
  const { t } = useTranslation()
  const { competitors } = series
  const extraShots = !!competitors.find(c => c.europeanRifleExtraShots)
  return (
    <div className="results--desktop">
      <table className="results-table">
        <thead>
        <tr>
          <th />
          <th>{t('name')}</th>
          <th>{t('numberShort')}</th>
          <th>{resolveClubTitle(t, race.clubLevel)}</th>
          <th>{t('european_rifle1')}</th>
          <th>{t('european_rifle2')}</th>
          <th>{t('european_rifle3')}</th>
          <th>{t('european_rifle4')}</th>
          <th>{t('result')}</th>
          {extraShots && <th>{t('extraRound')}</th>}
        </tr>
        </thead>
        <DesktopResultsRows competitors={competitors}>
          {competitor => {
            const {
              europeanRifleExtraShots,
              europeanRifleScore,
              europeanRifle1Score,
              europeanRifle1Shots,
              europeanRifle2Score,
              europeanRifle2Shots,
              europeanRifle3Score,
              europeanRifle3Shots,
              europeanRifle4Score,
              europeanRifle4Shots,
              noResultReason,
            } = competitor
            return (
              <>
                <td><ShootingResult score={europeanRifle1Score} shots={europeanRifle1Shots} /></td>
                <td><ShootingResult score={europeanRifle2Score} shots={europeanRifle2Shots} /></td>
                <td><ShootingResult score={europeanRifle3Score} shots={europeanRifle3Shots} /></td>
                <td><ShootingResult score={europeanRifle4Score} shots={europeanRifle4Shots} /></td>
                <td className="center total-points">
                  <TotalScore noResultReason={noResultReason} totalScore={europeanRifleScore} />
                  <EuropeanRifleNationalRecord race={race} series={series} competitor={competitor} />
                </td>
                {extraShots && <td>{europeanRifleExtraShots?.join(', ')}</td>}
              </>
            )
          }}
        </DesktopResultsRows>
      </table>
    </div>
  )
}
