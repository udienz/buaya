
from sedot.report.report import Generator

from sedot import SEDOT_CONFIG

from string import Template

class MirrorSizeGenerator(Generator):
	
	def __init__(self, outdir):
		Generator.__init__(self, outdir)

		self.report_name_short = "Size"
		self.report_name = "Mirror Size"
		self.output_file = "size.html"
	
	def _print_report(self, out):
		out.write("""
<div id="mirror-size">
	<table>
	<tr><th>Mirror</th>
		<th>Size</th>
		<th>&nbsp;</th>
	</tr>
""")

		template = Template("""
	<tr><td class="name">$mirror</td>
		<td class="size">$size</td>
		<td class="graph"><img src="mirror-size/$pkg.year.png" alt="$mirror"/></td>
	</tr>
""")

		pkgs = self.packages.keys()
		pkgs.sort(lambda a, b: cmp(self.packages[a].name.lower(), self.packages[b].name.lower()))

		for pkg in pkgs:

			package = self.packages[pkg]

			if not package.size.size:
				continue

			out.write(template.substitute(
				mirror=package.name,
				size=self._make_size(package.size.size),
				pkg=package.package
			))

		out.write("""
	</table>
</div>
""")
	
