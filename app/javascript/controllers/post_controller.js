import { Controller } from "@hotwired/stimulus"
import CableReady from 'cable_ready'

export default class extends Controller {
    static values = { id: String }

    connect() {
      this.channel = this.application.consumer.subscriptions.create(
        {
          channel: 'PostChannel',
          id: this.idValue
        },
        {
          received (data) { if (data.cableReady) CableReady.perform(data.operations) }
        }
      )
    }

    disconnect() {
        this.channel.unsubscribe()
    }
}
