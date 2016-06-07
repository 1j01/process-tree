
{exec} = require "child_process"

# TODO: allow pid to be ommitted; list all processes
module.exports = (pid, callback)->
	process_lister_command =
		if process.platform is "win32"
			"wmic PROCESS GET Name,ProcessId,ParentProcessId"
		else
			"ps -A -o ppid,pid,comm"
	
	process_lister = exec process_lister_command
	process_lister.on "error", callback
	stdout = ""
	stderr = ""
	process_lister.stdout.on "data", (data)-> stdout += data
	process_lister.stderr.on "data", (data)-> stderr += data
	process_lister.on "close", (code)->
		return callback new Error "Process `#{process_lister_command}` exited with code #{code}:\n#{stderr}" if code
		
		output = stdout.trim()
		# console.log "Output from `#{process_lister_command}`:\n#{output}"
		
		# TODO: maybe use https://github.com/namshi/node-shell-parser
		[headers, rows...] = output.split /\r?\n/
		header_keys = headers.toLowerCase().trim().split /\s+/
		proc_infos =
			for row in rows
				info = {}
				row_values = row.trim().split /\s+/
				for key, i in header_keys
					value = row_values[i] ? ""
					value = parseFloat(value) unless key.match(/name|comm|cmd/i) or isNaN(value)
					info[key] = value
				info
		
		procs =
			for info in proc_infos
				pid: info.pid ? info.processid
				ppid: info.ppid ? info.parentprocessid
				name: info.name ? info.comm ? info.cmd ? info.command
		
		children_of = (ppid)->
			for proc in procs when "#{proc.ppid}" is "#{ppid}"
				proc.children = children_of(proc.pid)
				proc
		
		callback null, children_of(pid)
