import _config  from 'app.config'
import Api from 'Api'
import Eth from 'Eth/Eth'
import QR from 'qrcode-svg'
import toastr from 'toastr'
import './wallet.less'

<wallet>
	<script>
		this._config = _config
		this.address = false
		this.balance = {
			eth: '...',
			bet: '...',
		}

		this.on('mount', ()=>{
			this.testnet = _config.network!=='mainnet'
			this.updateWallet()
		})

		this.updateWallet = ()=>{
			if (!Eth.Wallet.get().openkey) {
				setTimeout(()=>{
					this.updateWallet()
				},500)
				return
			}
			this.address = Eth.Wallet.get().openkey
			this.update()

			this.refs.wallet_qr_code.innerHTML = new QR({
				content:    this.address,
				padding:    2,
				width:      190,
				height:     190,
				color:      "#d99736",
				background: "#202020",
				ecl:        "M"
			}).svg()


			Eth.getEthBalance(this.address, (balance_eth)=>{
				if (balance_eth===0) {
					balance_eth = '0'
				}
				this.balance.eth = balance_eth
				this.update()
			})

			Eth.getBetsBalance(this.address, (balance_bet)=>{
				if (balance_bet===0) {
					balance_bet = '0'
				}
				this.balance.bet = balance_bet
				this.update()
			})
		}

		this.showPrivateKey = ()=>{

			Eth.Wallet.exportPrivateKey(private_key=>{

			})

		}

		this.copy = (e)=>{
			function copyToClipboard(text) {
				const input = document.createElement('input');
				input.style.position = 'fixed';
				input.style.opacity = 0;
				input.value = text;
				document.body.appendChild(input);
				input.select();
				document.execCommand('Copy');
				document.body.removeChild(input);
			};

			copyToClipboard( e.target.value )

			toastr.options.showDuration = 100
			toastr.options.hideDuration = 100
			toastr.options.timeOut = 1000
			toastr.options.extendedTimeOut = 100

			if (!this.toastshowed) {
				toastr.success('Address copied to clipboard', 'Copied')
				this.toastshowed = true
			}
			this.toast_t = setTimeout(()=>{
				this.toastshowed = false
			}, 2000)
		}

		this.getTestBets_proccess = false
		this.bets_requested = localStorage.getItem('bets_requested_'+_config.network)

		this.getTestBets = (e)=>{
			e.preventDefault()
			this.getTestBets_proccess = true
			this.update()

			Api.addBets(this.address).then(()=>{
				localStorage.setItem('bets_requested_'+_config.network, true)
				toastr.info('Request sended', 'Please waiting')
			})

		}
	</script>
	<div class="wallet-wrap">
		<div class="address" if={address}>
			<svg ref="wallet_qr_code"></svg>

			<a class="etherscan" href="{_config.etherscan_url}/address/{address}" target="_blank" rel="noopener">blockchain</a>

			<label>Account Address:</label>

			<input onclick={copy} type="text" value="{address}" size="42">
		</div>

		<div class={balance:true}>
			<button if={bets_requested} class="bets-requested">free bets requested</button>
			<button class={loading:getTestBets_proccess} if={testnet && !bets_requested} onclick={getTestBets}>get test bets</button>

			<label>Account Balance:</label>
			<span>
				<b if={!balance.eth} class="loading">:.</b>
				<b if={balance.eth}>{balance.eth}</b> ETH
			</span>
			<span>
				<b if={!balance.bet} class="loading">.:</b>
				<b if={balance.bet}>{balance.bet}</b> BET
			</span>

		</div>
	</div>
</wallet>
