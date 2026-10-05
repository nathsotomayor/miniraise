import { mount } from 'svelte'
import './application.css'
import Hello from '../components/Hello.svelte'

const target = document.getElementById('svelte-root')

if (target) {
  mount(Hello, { target })
}
