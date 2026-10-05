import { mount } from 'svelte'
import './application.css'
import InvestmentCheckout from '../components/InvestmentCheckout.svelte'

const target = document.getElementById('investment-checkout')

if (target) {
  mount(InvestmentCheckout, { target, props: { offeringId: target.dataset.offeringId } })
}
